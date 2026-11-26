#!/usr/bin/env bash
# Per-workspace-pill mouse handling: hover highlight + scroll to cycle the
# workspaces on that pill's monitor (Hyprland's `workspace, e+1` on mouse wheel).

source "$CONFIG_DIR/colors.sh"

ws="${NAME#workspace.}"

case "$SENDER" in
  mouse.entered)
    [ "$ws" = "$(aerospace list-workspaces --focused)" ] && exit 0
    sketchybar --animate tanh 10 --set "$NAME" background.color=$WS_HOVER_BG icon.color=$FG label.color=$FG
    ;;
  mouse.exited)
    # Let the controller restore the right style (inactive vs. visible-on-other-monitor).
    # Drop its "nothing changed" cache first: the hover changed the pill behind its back.
    rm -f "$(getconf DARWIN_USER_TEMP_DIR)sketchybar/controller.last"
    sketchybar --trigger aerospace_refresh
    ;;
  mouse.scrolled)
    # Focus the monitor under the pill first, so the wheel cycles *its* workspaces.
    # (monitor-id is the left-to-right sequence number focus-monitor accepts.)
    mon="$(aerospace list-workspaces --all --format '%{workspace}|%{monitor-id}' |
      awk -F'|' -v w="$ws" '$1 == w { print $2; exit }')"
    [ -n "$mon" ] && aerospace focus-monitor "$mon"
    if [ "${SCROLL_DELTA:-0}" -gt 0 ]; then
      aerospace workspace --wrap-around prev
    else
      aerospace workspace --wrap-around next
    fi
    ;;
esac
