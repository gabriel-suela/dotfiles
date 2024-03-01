#!/bin/bash

bspc subscribe node_state | while read -r _ _ _ _ state flag; do

	if [ "$state" != "fullscreen" ]; then

		continue

	fi

	if [ "$flag" == on ]; then

		/usr/local/bin/eww -c $HOME/.config/eww/vertical close-all

	else

		/usr/local/bin/eww -c $HOME/.config/eww/vertical open vertical

	fi

done &
