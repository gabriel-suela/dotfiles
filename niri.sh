#!/bin/bash

export XDG_CURRENT_DESKTOP="niri"
export XDG_SESSION_TYPE="wayland"
export XDG_SESSION_DESKTOP="niri"

sleep 2
killall xdg-desktop-portal-gnome
killall xdg-desktop-portal
/usr/lib/xdg-desktop-portal-gnome &
sleep 2
/usr/lib/xdg-desktop-portal &
