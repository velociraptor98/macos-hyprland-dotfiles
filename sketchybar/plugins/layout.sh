#!/usr/bin/env bash
# Layout indicator clicks (the icon itself is drawn by plugins/aerospace.sh).
#   left click  = toggle tiles horizontal <-> vertical   (alt-/)
#   right click = toggle accordion <-> tiles             (alt-w)

source "$CONFIG_DIR/plugins/hover.sh"   # mouse enter/leave: highlight island, exit

[ "$SENDER" = "mouse.clicked" ] || exit 0

if [ "$BUTTON" = "right" ]; then
  aerospace layout accordion tiles
else
  aerospace layout tiles horizontal vertical
fi
sketchybar --trigger aerospace_refresh
