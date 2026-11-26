#!/usr/bin/env bash
# CPU temperature, shown inside the CPU pill. Average of the CPU die sensors,
# read by helpers/cpu_temp (compiled by sketchybarrc). Hidden if unavailable.

source "$CONFIG_DIR/colors.sh"

temp="$("$CONFIG_DIR/helpers/cpu_temp" 2>/dev/null)"

case "$temp" in
  '' | *[!0-9]*)
    sketchybar --set "$NAME" drawing=off
    exit 0
    ;;
esac

if [ "$temp" -ge 85 ]; then color=$RED
elif [ "$temp" -ge 70 ]; then color=$YELLOW
else color=$TEAL
fi

sketchybar --set "$NAME" drawing=on icon.color=$color label="${temp}°C"
