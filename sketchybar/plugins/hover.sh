#!/usr/bin/env bash
# Island hover: brighten the island under the mouse.
# Sourced at the top of each island item's plugin (it exits there on mouse
# enter/leave, so the real update doesn't rerun), or used as the script itself
# for items without one. ISLAND names the bracket to light up (default: the item).

case "$SENDER" in
  mouse.entered | mouse.exited)
    source "$CONFIG_DIR/colors.sh"
    if [ "$SENDER" = "mouse.entered" ]; then bg=$BG_HOVER; edge=$EDGE_HOVER; else bg=$BG; edge=$EDGE; fi
    # A critical reading keeps the status island's edge red (see alert.sh).
    if [ "$ISLAND" = "status_island" ] &&
       [ -e "${SKETCHYBAR_RUNDIR:-$(getconf DARWIN_USER_TEMP_DIR)sketchybar}/alert_state.on" ]; then
      edge=$ALERT_EDGE
    fi
    sketchybar --animate tanh 10 --set "${ISLAND:-$NAME}" background.color=$bg background.border_color=$edge
    exit 0
    ;;
esac
