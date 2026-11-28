#!/usr/bin/env bash
# Shared item styles. Sourced by sketchybarrc and plugins/aerospace.sh
# (which rebuilds the workspace bracket when a new workspace name appears).

source "$CONFIG_DIR/colors.sh"

# A module group on the bar ("island"): an invisible capsule that lights up on hover
# (plugins/hover.sh) and carries the red alert ring. The glass itself is the bar
# (plugins/bar_bg.sh). The border stays 1px wide so the alert ring only needs a colour.
island=(
  background.drawing=on
  background.color=$TRANSPARENT
  background.border_color=$TRANSPARENT
  background.border_width=1
  background.corner_radius=16
  background.height=32
)

# Popup panel (calendar, battery, volume, power menu, mode hints).
# Add popup.align=left|center|right per item.
popup=(
  popup.background.color=$BG_POPUP
  popup.background.border_color=$EDGE
  popup.background.border_width=1
  popup.background.corner_radius=16
  popup.background.shadow.drawing=on
  popup.background.shadow.color=$SHADOW
  popup.background.shadow.angle=90
  popup.background.shadow.distance=4
  popup.y_offset=8
  popup.blur_radius=20
)

# One row inside a popup. Clickable rows also get script=popup_row.sh for hover.
popup_row=(
  icon.padding_left=12
  icon.padding_right=8
  label.padding_right=14
  background.color=$TRANSPARENT
  background.corner_radius=10
  background.height=28
)

# Rebuild the bracket that groups the workspace dots (hover capsule).
# Bracket members are fixed at creation, so new workspace items need this.
workspaces_bracket() {
  sketchybar --remove workspaces 2>/dev/null
  sketchybar --add bracket workspaces ws_pad_l '/workspace\..*/' ws_pad_r \
             --set workspaces "${island[@]}"
}
