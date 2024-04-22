#!/bin/bash

# Function to send notification with volume level
send_notification() {
	dunstify -a "Volume" -u low -t 1500 "Volume" "$1"
}

# Function to update existing notification
update_notification() {
	dunstify -r "$1" -a "Volume" -u low -t 1500 "Volume" "$2"
}

# Get current volume level
volume=$(pamixer --get-volume-human)

# Check if a notification with volume already exists
notification_id=$(dunstify -l 0 -a "Volume" -t 1500 "Volume" "$volume")

# Adjust volume
case "$1" in
"up")
	pamixer --increase 5
	;;
"down")
	pamixer --decrease 5
	;;
"toggle")
	pamixer --toggle-mute
	;;
esac

# Get updated volume level
new_volume=$(pamixer --get-volume-human)

# If a notification with volume exists, update it
if [ -n "$notification_id" ]; then
	update_notification "$notification_id" "$new_volume"
else
	send_notification "$new_volume"
fi
