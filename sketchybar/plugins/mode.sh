#!/usr/bin/env bash
# AeroSpace binding mode (Waybar's hyprland/submap module).
# Invisible in `main`; in `resize` / `service` a loud pill appears on the focused
# monitor with a which-key style popup listing that mode's keys (rows built in sketchybarrc).

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

mode="$(aerospace list-modes --current 2>/dev/null)"

case "$mode" in
  "" | main)
    sketchybar --set "$NAME" drawing=off popup.drawing=off
    exit 0
    ;;
esac

# Only on the focused monitor's bar.
display="$(aerospace list-monitors --focused --format '%{monitor-appkit-nsscreen-screens-id}' 2>/dev/null)"
case "$display" in [0-9]*) sketchybar --set "$NAME" display="$display" ;; esac

case "$mode" in
  resize)  icon=$ICON_MODE_RESIZE;  color=$ORANGE ;;
  service) icon=$ICON_MODE_SERVICE; color=$RED ;;
  *)       icon=$ICON_MODE_RESIZE;  color=$MAGENTA ;;
esac
label="$(printf '%s' "$mode" | tr '[:lower:]' '[:upper:]')"

sketchybar --set "$NAME" drawing=on icon="$icon" label="$label" \
             background.color=$color icon.color=$BG_SOLID label.color=$BG_SOLID \
           --set '/mode\.hint\..*/' drawing=off \
           --set "/mode\.hint\.$mode\..*/" drawing=on \
           --set mode.hint.title icon.color=$color drawing=on \
           --set "$NAME" popup.drawing=on
