# -------
# Restart
# -------

killall eww
killall polybar
killall picom
killall plank
killall stalonetray

#------
# Var's
# ------

EWW_BAR_PRIMARY="vertical"

CONFIG="$HOME/.config/"
EWW="/usr/local/bin/eww"

# -------
# Monitor
# -------

xrandr --output HDMI-0 --primary --mode 1920x1080 --rotate normal

# --------
# Fix java
# --------

# bash -c $CONFIG'bspwm/scripts/java_fix.sh'

# ---------
# Start EWW
# ---------

$EWW -c "$HOME/.config/eww/$EWW_BAR_PRIMARY" --restart open $EWW_BAR_PRIMARY

# ---------
# Wallpaper
# ---------
./.fehbg

# ------------
# X Cursor Fix
# ------------

xsetroot -cursor_name left_ptr &

# -------
# Borders
# -------

# bash $CONFIG'bspwm/borders'

# ------
# Picom
# ------

picom &
dunst &
xcompmg &

# ---------
# StartPage
# ---------

# php -S 127.0.0.1:7000 -t $HOME/.dotfiles/start-page/

# ---------
# Clipboard
# ---------

./.local/bin/greenclip daemon
