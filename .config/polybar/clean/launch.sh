#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch Polybar, using default config location ~/.config/polybar/config
polybar workspaces --config=~/.config/polybar/clean/config.ini &
polybar volume --config=~/.config/polybar/clean/config.ini &
polybar layout --config=~/.config/polybar/clean/config.ini &
polybar time --config=~/.config/polybar/clean/config.ini &
polybar tray --config=~/.config/polybar/clean/config.ini &
# polybar second --config=~/.config/polybar/config.ini &

echo "Polybar launched..."
