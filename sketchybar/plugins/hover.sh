#!/usr/bin/env bash
# Group hover: light up the module group under the mouse; flash it briefly on click.
# Sourced at the top of each island item's plugin (it exits there on mouse
# enter/leave, so the real update doesn't rerun; clicks fall through to the
# plugin), or used as the script itself for items without one.
# ISLAND names the bracket to light up (default: the item).

case "$SENDER" in
  mouse.entered | mouse.exited)
    source "$CONFIG_DIR/colors.sh"
    if [ "$SENDER" = "mouse.entered" ]; then bg=$BG_HOVER; edge=$EDGE_HOVER; else bg=$TRANSPARENT; edge=$TRANSPARENT; fi
    # A critical reading keeps the status island's edge red (see alert.sh).
    if [ "$ISLAND" = "status_island" ] &&
       [ -e "${SKETCHYBAR_RUNDIR:-$(getconf DARWIN_USER_TEMP_DIR)sketchybar}/alert_state.on" ]; then
      edge=$ALERT_EDGE
    fi
    sketchybar --animate tanh 10 --set "${ISLAND:-$NAME}" background.color=$bg background.border_color=$edge
    exit 0
    ;;
  mouse.clicked)
    source "$CONFIG_DIR/colors.sh"
    # Flash, then settle back on the hover colour (the mouse is still over it).
    sketchybar --animate tanh 6 --set "${ISLAND:-$NAME}" background.color=$BG_FLASH background.color=$BG_HOVER &
    ;;
esac
