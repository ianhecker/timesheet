#!/bin/bash

set -e

if ! command -v gum &> /dev/null
then
    echo "gum was not found - check your installation"
    exit 1
fi

function gum_print() {
	gum style --foreground 212 "$1" 1>&2
}

gum_print "* gum installation was found!"

# Create config directory & config
CONFIG_DIR="$HOME/.config/timesheet"
mkdir -p $CONFIG_DIR
cp .config.sh "$CONFIG_DIR/.config.sh"
cp .timesheet "$CONFIG_DIR/.timesheet"
gum_print "* Copied .config and .timesheet to $CONFIG_DIR"

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

gum_print "* Setup done!"
