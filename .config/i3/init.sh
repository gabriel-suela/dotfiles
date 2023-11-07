#!/bin/sh
xrdb merge ~/.Xresourses &
xset s 300 &
xset r rate 300 50 &
picom --config ~/.config/picom/picom.conf &
i3-msg "restart"

