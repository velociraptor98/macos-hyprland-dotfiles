#!/usr/bin/env bash
# Drives both clock items: `date` (Wed 25 Nov) and `clock` (14:32).
# Clicking either opens the calendar popup (attached to `date`).

source "$CONFIG_DIR/plugins/hover.sh"   # mouse enter/leave: highlight island, exit

case "$SENDER" in
  mouse.clicked)
    exec "$CONFIG_DIR/plugins/calendar.sh"
    ;;
  mouse.exited.global)
    sketchybar --set clock_island popup.drawing=off
    exit 0
    ;;
esac

case "$NAME" in
  date) sketchybar --set "$NAME" label="$(date '+%a %d %b')" ;;
  *)    sketchybar --set "$NAME" label="$(date '+%H:%M')" ;;
esac
