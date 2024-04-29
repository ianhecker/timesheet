#!/bin/bash

set -e

CONFIG_DIR="$HOME/.config/timesheet"
CONFIG="$CONFIG_DIR/.config"

if ! test -f "$CONFIG"; then
  echo "Could not find $CONFIG"
  exit 1
fi

source $CONFIG

if ! test -f "$PROJECT_CONFIG"
then
	echo "Could not find $PROJECT_CONFIG"
	exit 1
fi

MONTHS=("January" "February" "March" "April" "May" "June" "July" "August" "September" "October" "November" "December")

# If more times are desired, edit the right brace expansion
# MILITARY_TIMES=$(echo -e {00..23}:{00,.59})
MILITARY_TIMES=$(echo -e {00..23}:{00,15,30,45})

function days_in_month() {
	MONTH=$1
	YEAR=$2

	date -d "$MONTH/1/$YEAR + 1 month - 1 day" "+%d"
}

function get_day() {
	DAYS_IN_MONTH=$1

	DAYS=$(for i in `seq 1 $DAYS_IN_MONTH`; do echo $i; done)

	TODAY=$(date +%d)
	gum filter --indicator ">" --height 10 --placeholder "today is $TODAY" $DAYS
}

function get_details() {
	gum input --placeholder "I did a thing!"
}

function get_military_time() {
	gum filter --indicator ">" --height 10 ${MILITARY_TIMES[@]}
}

function get_month() {
	THIS_MONTH=$(date +%B)
	gum choose --selected $THIS_MONTH --height 12 "${MONTHS[@]}"
}

function get_project() {
	cat $PROJECT_CONFIG | gum filter --indicator ">" --height 10
}

function get_year() {
	date +%Y
}

function gum_print() {
	gum style --foreground 212 --padding "0 2" "$1" 1>&2
}

function prompt() {
	echo $1 1>&2
}

function month_atoi() {
	date -d "01 $1" "+%m"
}

YEAR=$(get_year)

prompt "Enter Month"
MONTH_STR=$(get_month)
gum_print "* $MONTH_STR"

MONTH_INT=$(month_atoi $MONTH_STR)
DAYS_IN_MONTH=$(days_in_month $MONTH_INT $YEAR)

prompt "Enter Day"
DAY=$(get_day $DAYS_IN_MONTH)
gum_print "* $DAY"

prompt "Enter Start Time (military time)"
START="$(get_military_time):00"
gum_print "* $START"

prompt "Enter Stop Time (military time)"
STOP="$(get_military_time):00"
gum_print "* from $START until $STOP"

prompt "Select Task"
TASK=$(get_project)
gum_print "* $TASK"

prompt "Enter Details"
DETAILS=$(get_details)
gum_print "* $DETAILS"

ISO_8601_START=$(date +"${YEAR}-${MONTH_INT}-${DAY}T${START}%:z")
ISO_8601_STOP=$(date +"${YEAR}-${MONTH_INT}-${DAY}T${STOP}%:z")

ENTRY="$ISO_8601_START,$ISO_8601_STOP,$TASK,\"$DETAILS\""
HASH=$(echo $ENTRY | sha256sum | cut -d" " -f1)

gum_print "* $HASH,$ENTRY"
echo "$HASH,$ENTRY" >> $OUTPUT_FILE
