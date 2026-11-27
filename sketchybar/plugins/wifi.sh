#!/usr/bin/env bash
# Network (Waybar's network module). macOS redacts the SSID for
# non-entitled processes, so this is icon-only: connected / disconnected.

source "$CONFIG_DIR/plugins/hover.sh"   # mouse enter/leave: highlight island, exit
[ "$SENDER" = "mouse.clicked" ] && exit 0   # flash done; click_script opens the app

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

dev="${WIFI_DEV:-$(networksetup -listallhardwareports | awk '/Wi-Fi/ { getline; print $2; exit }')}"   # passed in by sketchybarrc
ip="$(ipconfig getifaddr "${dev:-en0}" 2>/dev/null)"

if [ -n "$ip" ]; then
  sketchybar --set "$NAME" icon="$ICON_WIFI" icon.color=$ICON_DIM
else
  sketchybar --set "$NAME" icon="$ICON_WIFI_OFF" icon.color=$RED
fi
