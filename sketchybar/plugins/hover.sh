#!/usr/bin/env bash
# Island hover: brighten the island under the mouse.
# Sourced at the top of each island item's plugin (it exits there on mouse
# enter/leave, so the real update doesn't rerun), or used as the script itself
# for items without one. ISLAND names the bracket to light up (default: the item).

case "$SENDER" in
  mouse.entered | mouse.exited)
    source "$CONFIG_DIR/colors.sh"
    if [ "$SENDER" = "mouse.entered" ]; then bg=$BG_HOVER; edge=$EDGE_HOVER; else bg=$BG; edge=$EDGE; fi
    sketchybar --animate tanh 10 --set "${ISLAND:-$NAME}" background.color=$bg background.border_color=$edge
    exit 0
    ;;
esac
