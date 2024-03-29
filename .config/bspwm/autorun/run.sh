# -------
# Restart
# -------
killall eww
killall polybar
killall compfy
killall sxhkd
#------
# Var's
# ------
EWW_BAR_PRIMARY="vertical"

CONFIG="$HOME/.config/"
EWW="/usr/local/bin/eww"

# ---------
# Start EWW
# ---------

# $EWW -c "$HOME/.config/eww/$EWW_BAR_PRIMARY" --restart open $EWW_BAR_PRIMARY

# ---------
# Wallpaper
# ---------
./.fehbg

# ------------
# X Cursor Fix
# ------------

xsetroot -cursor_name left_ptr &
xset s off &
xset -dpms &
xset s noblank &
sxhkd &

# ------
# Autostart
# ------

compfy --config ~/.config/compfy/compfy.sample.conf &
~/.config/polybar/clean/launch.sh &
dunst &
