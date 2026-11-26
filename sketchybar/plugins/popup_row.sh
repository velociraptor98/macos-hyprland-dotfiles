#!/usr/bin/env bash
# Hover highlight for clickable popup rows (power menu, "… settings" rows).

source "$CONFIG_DIR/colors.sh"

case "$SENDER" in
  mouse.entered) sketchybar --animate tanh 8 --set "$NAME" background.color=$BG_HIGHLIGHT ;;
  mouse.exited)  sketchybar --animate tanh 8 --set "$NAME" background.color=$TRANSPARENT ;;
esac
