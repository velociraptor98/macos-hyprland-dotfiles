#!/usr/bin/env bash
# Drives both clock items: `date` (Wed 25 Nov) and `clock` (14:32).
# Clicking either opens the calendar popup (attached to `date`).

case "$SENDER" in
  mouse.clicked)
    exec "$CONFIG_DIR/plugins/calendar.sh"
    ;;
  mouse.exited.global)
    sketchybar --set date popup.drawing=off
    exit 0
    ;;
esac

case "$NAME" in
  date) sketchybar --set "$NAME" label="$(date '+%a %d %b')" ;;
  *)    sketchybar --set "$NAME" label="$(date '+%H:%M')" ;;
esac
