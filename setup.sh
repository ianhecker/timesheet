#!/bin/bash

set -e

if ! command -v gum &> /dev/null
then
    echo "gum was not found - check your installation"
    exit 1
else
	gum style --foreground 212 'gum was found!'
fi

function cleanup {
	echo "All done!"
}
trap finish EXIT

function gum_print() {
	gum style --foreground 212 "$1" 1>&2
}

# Create config directory
CONFIG_DIR="$HOME/.config/timesheet"
mkdir -p $CONFIG_DIR

CONFIG="$CONFIG_DIR/.config"
cp .config $CONFIG

# Add project list (ex. Epics in an Agile Sprint)
gum_print "* Enter your list of projects (CTRL + d to Save)"
gum write --placeholder "(Press Enter to add newlines)" > "$CONFIG_DIR/.projects"
cat "$CONFIG_DIR/.projects"

# Optional step to check your settings
gum_print "* Let's double-check your settings!"
while gum confirm "Edit your configs? (Optional)" && true || false
do
	FILE=$(gum file --all $CONFIG_DIR)
	$EDITOR $FILE
done
