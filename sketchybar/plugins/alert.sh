#!/usr/bin/env bash
# Status group warning ring. Sourced by battery.sh, cpu_temp.sh and memory.sh:
#   island_alert <key> on|off
# Each plugin raises/clears its own flag file; the island edge is red while any
# flag is up. sketchybar is only called when the island's state actually flips.

ALERT_DIR="${SKETCHYBAR_RUNDIR:-$(getconf DARWIN_USER_TEMP_DIR)sketchybar}"

island_alert() {
  mkdir -m 700 -p "$ALERT_DIR"
  if [ "$2" = on ]; then : > "$ALERT_DIR/alert.$1"; else rm -f "$ALERT_DIR/alert.$1"; fi

  local now=off was=off f
  for f in "$ALERT_DIR"/alert.*; do [ -e "$f" ] && now=on && break; done
  [ -e "$ALERT_DIR/alert_state.on" ] && was=on
  [ "$now" = "$was" ] && return

  if [ "$now" = on ]; then
    : > "$ALERT_DIR/alert_state.on"
    sketchybar --animate tanh 15 --set status_island background.border_color=$ALERT_EDGE
  else
    rm -f "$ALERT_DIR/alert_state.on"
    sketchybar --animate tanh 15 --set status_island background.border_color=$TRANSPARENT
  fi
}
