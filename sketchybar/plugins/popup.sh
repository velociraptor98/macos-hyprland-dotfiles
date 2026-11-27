#!/usr/bin/env bash
# Popup helpers. Popups open instantly: every popup row is its own window, so a
# slide animation moves them all separately and looks jittery.
#
#   popup_open <item> / popup_toggle <item>       plain item popups (power menu, mode hints)
#   island_popup_toggle <island> "<rows>" "<other rows>" [min_width]
#       Popup hanging from a whole island (bracket), as wide as the island (or
#       min_width if wider). <rows> are this menu's rows; <other rows> belong to
#       another menu sharing the island and are hidden. If this menu is already
#       open, it closes; if the other one is, it switches.
#   island_popup_close <island>

popup_is_open() { # item
  sketchybar --query "$1" | awk '/"popup"/ { p = 1 } p && /"drawing"/ { print; exit }' | grep -q '"on"'
}

popup_open()   { sketchybar --set "$1" popup.drawing=on; }
popup_toggle() { if popup_is_open "$1"; then sketchybar --set "$1" popup.drawing=off; else popup_open "$1"; fi; }

island_popup_close() { sketchybar --set "$1" popup.drawing=off; }

island_popup_toggle() { # island "rows" "other rows" [min_width]
  local island="$1" rows="$2" others="$3" minw="${4:-0}" first="${2%% *}" row w
  if popup_is_open "$island" &&
     sketchybar --query "$first" | awk '/"drawing"/ { print; exit }' | grep -q '"on"'; then
    island_popup_close "$island"
    return
  fi

  # Island width on screen (all displays draw it the same width).
  w="$(sketchybar --query "$island" | awk '/"size"/ { gsub(/[^0-9. ]/, " "); print int($1); exit }')"
  [ -z "$w" ] && w=0
  [ "$w" -lt "$minw" ] && w=$minw

  local args=()
  for row in $rows; do
    case "$row" in
      *slider*) args+=(--set "$row" slider.width=$((w - 24))) ;;   # 12px padding each side
      *)        args+=(--set "$row" width="$w") ;;
    esac
    [ -n "$others" ] && args+=(--set "$row" drawing=on)
  done
  for row in $others; do args+=(--set "$row" drawing=off); done
  sketchybar "${args[@]}" --set "$island" popup.drawing=on
}
