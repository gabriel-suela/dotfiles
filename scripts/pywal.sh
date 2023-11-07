#!/usr/bin/env bash
# This is a Pywal wrapper script that is shown in TesterTech's YT video's
# Free to use it for your own workflow. No guarantees given on proper operation.
# ~ Script source ~
# https://github.com/TesterTech/rice-i3-from-scratch-pywal
#
# YT: https://www.youtube.com/@testertech
# GH: https://github.com/testertech


# Color files
POLYBAR_FILE="$HOME/.config/polybar/colors.ini" # this is very specific! :(
ROFI_FILE="$HOME/.config/rofi/colors.rasi"
WAL_FILE="$HOME/.cache/wal/colors.sh"
KONSOLE_FILE="$HOME/.local/share/konsole/pywal.colorscheme"
PLASMA_COLORS_DIR="$HOME/.local/share/color-schemes/"
PLASMA_COLORS_FILE="PywalColorScheme.colors"
PLASMA_SHELL_EXECUTABLE="plasmashell"

pywal_get() {
wal -i "$1" -q
}

# Change colors
change_color() {
	# polybar
	sed -i -e "s/foreground = #.*/foreground = $FG/g" $POLYBAR_FILE
	sed -i -e "s/background = #.*/background = $BG/g" $POLYBAR_FILE
	sed -i -e "s/primary = #.*/primary = $AC1/g" $POLYBAR_FILE
	sed -i -e "s/secondary = #.*/secondary = $AC2/g" $POLYBAR_FILE
	sed -i -e "s/background-alt = #.*/background-alt = $AC3/g" $POLYBAR_FILE
	sed -i -e "s/foreground-alt = #.*/foreground-alt = $AC4/g" $POLYBAR_FILE
	sed -i -e "s/foreground-alt2 = #.*/foreground-alt2 = $AC5/g" $POLYBAR_FILE
	sed -i -e "s/foreground-alt3 = #.*/foreground-alt3 = $AC6/g" $POLYBAR_FILE

	# rofi
	cat > $ROFI_FILE <<- EOF
	/* colors */
	* {
	  foreground: ${FG};
	  background: ${BG};
	  primary: ${AC1};
	  secondary: ${AC2};
	  background-alt: ${AC3};
	  foreground-alt: ${AC4};
	  foreground-alt2: ${AC5};
	  foreground-alt3: ${AC6};
	}
	EOF

	polybar-msg cmd restart
}

set_wallpaper_using_feh() {
    echo ">> Set the wallpaper "$1" using feh"
    feh --bg-fill "$1"
}

copy_konsole_colorscheme() {
    echo ">> Copy Konsole colorscheme to 'home local share'"
    cp -f $HOME/.cache/wal/colors-konsole.colorscheme $KONSOLE_FILE
    echo ">> and set transparency to 20%"
    sed -i -e "s/Opacity=.*/Opacity=0.8/g" $KONSOLE_FILE
}
merge_xresources_color() {
    xrdb -merge $HOME/.cache/wal/colors.Xresources
}
get_xres_rgb() {
	hex=$(xrdb -query | grep "$1" | awk '{print $2}' | cut -d# -f2)
	printf "%d,%d,%d\n" "0x${hex:0:2}" "0x${hex:2:2}" "0x${hex:4:2}"
}

# Main
if [[ -x "`which wal`" ]]; then
	if [[ "$1" ]]; then
		pywal_get "$1" "$2"

		# Source the pywal color file
		if [[ -e "$WAL_FILE" ]]; then
			. "$WAL_FILE"
		else
			echo 'Color file does not exist, exiting...'
            echo '1) Is ImageMagick installed?'
            echo '2) Try to run wal --> f.e. wal -i ~/Pictures/<yourimage>.jpg'
            echo 'should result in ~/.cache/wal dir being filled with files (also the color.sh file)'
			exit 1
		fi

		BG=`printf "%s\n" "$background"`
		FG=`printf "%s\n" "$foreground"`
		AC1=`printf "%s\n" "$color1"`
		AC2=`printf "%s\n" "$color2"`
		AC3=`printf "%s\n" "$color3"`
		AC4=`printf "%s\n" "$color4"`
		AC5=`printf "%s\n" "$color5"`
		AC6=`printf "%s\n" "$color6"`
		AC7=`printf "%s\n" "$color7"`
		AC8=`printf "%s\n" "$color8"`
		AC9=`printf "%s\n" "$color9"`
		AC10=`printf "%s\n" "$color10"`
		AC11=`printf "%s\n" "$color11"`
		AC12=`printf "%s\n" "$color12"`
		AC13=`printf "%s\n" "$color13"`
		AC14=`printf "%s\n" "$color14"`
		AC15=`printf "%s\n" "$color15"`
		AC66=`printf "%s\n" "$color66"`

		change_color
		set_wallpaper_using_feh "$1"
		copy_konsole_colorscheme
		#merge_xresources_color
		./alacritty.sh
		if [[ -x "`which ${PLASMA_SHELL_EXECUTABLE}`" ]];
		then
			plasma_color_scheme
		else
			echo "ERROR plasmashell: cannot is NOT installed! Cannot set plasma's (kde) color scheme"
		fi

	else
		echo -e "[!] Please enter the path to wallpaper. \n"
		echo "Usage : ./pywal.sh path/to/image"
	fi
else
	echo "[!] 'pywal' is not installed. https://pypi.org/project/pywal/"
fi
