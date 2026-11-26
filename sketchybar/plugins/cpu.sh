#!/usr/bin/env bash
# Total CPU usage, normalised to 0-100% across all cores.

source "$CONFIG_DIR/colors.sh"

ncpu="$(sysctl -n hw.ncpu)"
usage="$(ps -A -o %cpu= | awk -v n="$ncpu" '{ s += $1 } END { v = s / n; if (v > 100) v = 100; printf "%d", v }')"

if [ "$usage" -ge 80 ]; then color=$RED
elif [ "$usage" -ge 50 ]; then color=$YELLOW
else color=$BLUE
fi

sketchybar --set "$NAME" icon.color=$color label="${usage}%"
