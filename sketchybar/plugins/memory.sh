#!/usr/bin/env bash
# Memory in use (100 - "System-wide memory free percentage").

source "$CONFIG_DIR/colors.sh"

free="$(memory_pressure 2>/dev/null | awk -F': ' '/free percentage/ { gsub("%", "", $2); print $2 }')"
[ -z "$free" ] && exit 0
used=$((100 - free))

if [ "$used" -ge 85 ]; then color=$RED
elif [ "$used" -ge 70 ]; then color=$YELLOW
else color=$MAGENTA
fi

sketchybar --set "$NAME" icon.color=$color label="${used}%"
