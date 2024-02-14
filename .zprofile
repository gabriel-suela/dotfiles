if [[ "$(tty)" = "/dev/tty1" ]]; then
  # pgrep Hyprland || startx ~/.config/X11/Hyprland
fi

eval "$(gh completion -s zsh)"
