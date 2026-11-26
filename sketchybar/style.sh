#!/usr/bin/env bash
# Shared item styles. Sourced by sketchybarrc and plugins/aerospace.sh
# (which rebuilds the workspace bracket when a new workspace name appears).

source "$CONFIG_DIR/colors.sh"

# A floating Waybar module: dark translucent pill with a subtle border.
island=(
  background.drawing=on
  background.color=$BG
  background.border_color=$BORDER
  background.border_width=2
  background.corner_radius=12
  background.height=32
)

# Popup panel (calendar, battery, volume, power menu, mode hints).
# Add popup.align=left|center|right per item.
popup=(
  popup.background.color=$BG_SOLID
  popup.background.border_color=$BORDER
  popup.background.border_width=2
  popup.background.corner_radius=12
  popup.y_offset=8
  popup.blur_radius=20
)

# One row inside a popup. Clickable rows also get script=popup_row.sh for hover.
popup_row=(
  icon.padding_left=12
  icon.padding_right=8
  label.padding_right=14
  background.color=$TRANSPARENT
  background.corner_radius=8
  background.height=28
)

# Rebuild the bracket that draws the island behind the workspace pills.
# Bracket members are fixed at creation, so new workspace items need this.
workspaces_bracket() {
  sketchybar --remove workspaces 2>/dev/null
  sketchybar --add bracket workspaces ws_pad_l '/workspace\..*/' ws_pad_r \
             --set workspaces "${island[@]}"
}
