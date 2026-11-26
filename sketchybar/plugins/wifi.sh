#!/usr/bin/env bash
# Network (Waybar's network module). macOS redacts the SSID for
# non-entitled processes, so this is icon-only: connected / disconnected.

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

dev="$(networksetup -listallhardwareports | awk '/Wi-Fi/ { getline; print $2; exit }')"
ip="$(ipconfig getifaddr "${dev:-en0}" 2>/dev/null)"

if [ -n "$ip" ]; then
  sketchybar --set "$NAME" icon="$ICON_WIFI" icon.color=$CYAN
else
  sketchybar --set "$NAME" icon="$ICON_WIFI_OFF" icon.color=$RED
fi
