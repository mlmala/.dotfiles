#!/usr/bin/env bash

# Usage
usage() {
	echo -e "Usage: $0 <flatpak_app> [absolute_path_to_add]"
	echo -e "The program is an alias to:"
	echo -e "\t'flatpak override --user --filesystem=absolute_path_to_add flatpak_app'"
	echo -e "!! The default path is the entire home directory                   !!"
	echo -e "!! Stay safe adding single directories with [absolute_path_to_add] !!"
}

# Help?
if [ "$1" == "-h" ]; then
	usage
	exit 0
fi
if [ "$1" == "--help" ]; then
	usage
	exit 0
fi
if [ "$1" == "help" ]; then
	usage
	exit 0
fi

# Validate input
if [ "$1" == "" ]; then
	usage
	exit 1
fi
FLATPAK_APP="$1"
PATH_TO_ADD="${2:-$HOME}"
PRIMARY=$(xrandr | awk '/ primary/ {print $1; exit}')

flatpak override --user --filesystem=$PATH_TO_ADD $FLATPAK_APP
notify-send "$PRIMARY" "[flatpak] Added $PATH_TO_ADD to $FLATPAK_APP filesystem."
