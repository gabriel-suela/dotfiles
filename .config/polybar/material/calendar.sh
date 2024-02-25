#!/bin/sh

# Get the current user
USER=$(whoami)

# Get the current date
DATE=$(date +"%B %d, %Y")

# Get the screen width
SCREEN_WIDTH=1920

# Calculate the x position for the calendar popup to center it horizontally
POSX=$(((SCREEN_WIDTH - 1000) / 2))

case "$1" in
--popup)
	yad --calendar --fixed \
		--posx="$POSX" --posy=150 --no-buttons --borders=0 --title="yad-calendar" \
		--close-on-unfocus
	;;
*)
	echo "$DATE"
	;;
esac
