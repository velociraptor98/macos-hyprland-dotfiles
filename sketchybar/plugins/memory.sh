#!/usr/bin/env bash
# Memory in use (100 - "System-wide memory free percentage").

source "$CONFIG_DIR/plugins/hover.sh"   # mouse enter/leave: highlight island, exit
[ "$SENDER" = "mouse.clicked" ] && exit 0   # flash done; click_script opens the app

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/plugins/alert.sh"

free="$(memory_pressure 2>/dev/null | awk -F': ' '/free percentage/ { gsub("%", "", $2); print $2 }')"
[ -z "$free" ] && exit 0
used=$((100 - free))

if [ "$used" -ge 85 ]; then color=$RED
elif [ "$used" -ge 70 ]; then color=$YELLOW
else color=$ICON_DIM
fi

sketchybar --set "$NAME" icon.color=$color label="${used}%"
if [ "$used" -ge 85 ]; then island_alert memory on; else island_alert memory off; fi
