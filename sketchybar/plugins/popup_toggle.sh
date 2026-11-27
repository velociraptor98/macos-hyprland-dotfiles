#!/usr/bin/env bash
# Generic popup parent (e.g. the logo's power menu):
# click toggles the popup, moving the mouse off the bar closes it.

source "$CONFIG_DIR/plugins/hover.sh"   # mouse enter/leave: highlight island, exit

source "$CONFIG_DIR/plugins/popup.sh"

case "$SENDER" in
  mouse.clicked)          popup_toggle "$NAME" ;;
  mouse.exited.global)    sketchybar --set "$NAME" popup.drawing=off ;;
esac
