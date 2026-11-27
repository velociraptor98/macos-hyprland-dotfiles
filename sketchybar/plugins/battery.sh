#!/usr/bin/env bash
# Battery: icon + %, and a click-only popup with power source and time remaining.

source "$CONFIG_DIR/plugins/hover.sh"   # mouse enter/leave: highlight island, exit

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"
source "$CONFIG_DIR/plugins/popup.sh"
source "$CONFIG_DIR/plugins/alert.sh"

if [ "$SENDER" = "mouse.exited.global" ]; then
  island_popup_close status_island
  exit 0
fi

batt="$(pmset -g batt)"
pct="$(printf '%s' "$batt" | grep -Eo '[0-9]+%' | head -1 | tr -d '%')"

if [ -z "$pct" ]; then
  sketchybar --set "$NAME" drawing=off
  island_alert battery off
  exit 0
fi

case "$pct" in
  9[0-9] | 100) icon=$ICON_BAT_100; color=$ICON_DIM ;;
  [6-8][0-9])   icon=$ICON_BAT_75;  color=$ICON_DIM ;;
  [3-5][0-9])   icon=$ICON_BAT_50;  color=$ICON_DIM ;;
  [1-2][0-9])   icon=$ICON_BAT_25;  color=$YELLOW ;;
  *)            icon=$ICON_BAT_0;   color=$RED ;;
esac

on_ac=false
if printf '%s' "$batt" | grep -q 'AC Power'; then
  on_ac=true
  icon=$ICON_BAT_CHARGING
  color=$GREEN
fi

sketchybar --set "$NAME" drawing=on icon="$icon" icon.color=$color label="${pct}%"
# Below 20% and not on the charger: red island edge.
if [ "$on_ac" = false ] && [ "$pct" -lt 20 ]; then island_alert battery on; else island_alert battery off; fi

[ "$SENDER" = "mouse.clicked" ] || exit 0

# ── Popup (click only) ───────────────────────────────────────────────────────
# e.g. "80%; AC attached; not charging present: true"
#      "62%; discharging; 3:41 remaining present: true"
#      "45%; charging; (no estimate) present: true"
info="$(printf '%s\n' "$batt" | sed -n 2p | cut -f2)"
state="$(printf '%s' "$info" | cut -d';' -f2 | sed 's/^ *//')"
eta="$(printf '%s' "$info" | grep -Eo '[0-9]+:[0-9]+' | head -1)"

case "$state" in
  discharging)        status="${eta:+$eta remaining}" ;;
  charging)           status="${eta:+$eta until full}" ;;
  charged)            status="Fully charged" ;;
  "finishing charge") status="Finishing charge" ;;
  *)                  status="Not charging" ;;
esac
[ -z "$status" ] && status="Estimating…"

if [ "$on_ac" = true ]; then source_label="Power adapter · ${pct}%"; else source_label="Battery · ${pct}%"; fi

sketchybar --set battery.source label="$source_label" \
           --set battery.time label="$status"
island_popup_toggle status_island "battery.source battery.time battery.settings" "volume.slider volume.settings"
