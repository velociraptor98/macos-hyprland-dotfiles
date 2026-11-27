#!/usr/bin/env bash
# AeroSpace binding mode (Waybar's hyprland/submap module).
# Invisible in `main`; in `resize` / `service` a loud pill pops in on the focused
# monitor with a which-key style popup listing that mode's keys (rows built in sketchybarrc).
# The pill grows from a sliver on enter and shrinks away on exit.

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"
source "$CONFIG_DIR/plugins/popup.sh"

RUNDIR="${SKETCHYBAR_RUNDIR:-$(getconf DARWIN_USER_TEMP_DIR)sketchybar}"
SHOWN="$RUNDIR/mode.shown"
CLEAR_FG="0x00${BG_SOLID#0xff}"   # pill text colour, fully transparent

mode="$(aerospace list-modes --current 2>/dev/null)"

case "$mode" in
  "" | main)
    if [ -e "$SHOWN" ]; then
      rm -f "$SHOWN"
      sketchybar --set "$NAME" popup.drawing=off \
                 --animate tanh 8 --set "$NAME" background.height=0 icon.color=$CLEAR_FG label.color=$CLEAR_FG
      # Hide once it has shrunk — unless a mode was entered again meanwhile.
      ( sleep 0.15; [ -e "$SHOWN" ] || sketchybar --set "$NAME" drawing=off ) &
    else
      sketchybar --set "$NAME" drawing=off popup.drawing=off
    fi
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

start=()
if [ ! -e "$SHOWN" ]; then                       # entering from main: start as a sliver
  mkdir -m 700 -p "$RUNDIR"; : > "$SHOWN"
  start=(background.height=8 icon.color=$CLEAR_FG label.color=$CLEAR_FG)
fi

sketchybar --set "$NAME" drawing=on icon="$icon" label="$label" background.color=$color "${start[@]}" \
           --set '/mode\.hint\..*/' drawing=off \
           --set "/mode\.hint\.$mode\..*/" drawing=on \
           --set mode.hint.title icon.color=$color drawing=on \
           --animate tanh 10 --set "$NAME" background.height=32 icon.color=$BG_SOLID label.color=$BG_SOLID
popup_open "$NAME"
