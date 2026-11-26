#!/usr/bin/env bash
# Volume (Waybar's pulseaudio module).
#   left click  = slider popup     right click = mute
#   scroll      = +/- 5%           mouse leaves the bar = close popup

source "$CONFIG_DIR/plugins/hover.sh"   # mouse enter/leave: highlight island, exit

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

case "$SENDER" in
  mouse.exited.global)
    sketchybar --set "$NAME" popup.drawing=off
    exit 0
    ;;
  mouse.clicked)
    if [ "$BUTTON" = "right" ]; then
      osascript -e 'set volume output muted (not output muted of (get volume settings))'
    else
      sketchybar --set "$NAME" popup.drawing=toggle
    fi
    ;;
  mouse.scrolled)
    # Only set it: the volume_change event that follows redraws the item, so
    # reading the volume back here would be a second ~100ms osascript per notch.
    if [ "${SCROLL_DELTA:-0}" -gt 0 ]; then step=5; else step=-5; fi
    osascript -e "set volume output volume ((output volume of (get volume settings)) + $step)"
    exit 0
    ;;
esac

settings="$(osascript -e 'get volume settings')"
vol="$(printf '%s' "$settings" | sed -E 's/.*output volume:([0-9]+|missing value).*/\1/')"
muted="$(printf '%s' "$settings" | sed -E 's/.*output muted:([a-z ]+).*/\1/')"

# Some outputs (e.g. HDMI/DisplayPort audio) don't expose a volume.
case "$vol" in
  '' | *[!0-9]*) vol="--" ;;
esac

if [ "$muted" = "true" ] || [ "$vol" = "0" ]; then
  icon=$ICON_VOL_MUTE; color=$COMMENT
elif [ "$vol" = "--" ]; then
  icon=$ICON_VOL_HIGH; color=$GREEN
elif [ "$vol" -ge 60 ]; then
  icon=$ICON_VOL_HIGH; color=$GREEN
elif [ "$vol" -ge 30 ]; then
  icon=$ICON_VOL_MED; color=$GREEN
else
  icon=$ICON_VOL_LOW; color=$GREEN
fi

label="${vol}%"
[ "$vol" = "--" ] && label="--"

args=(--set "$NAME" icon="$icon" icon.color=$color label="$label")
if [ "$vol" != "--" ]; then
  slider_color=$GREEN
  [ "$muted" = "true" ] && slider_color=$COMMENT
  args+=(--set volume.slider slider.percentage="$vol" slider.highlight_color=$slider_color)
fi
sketchybar "${args[@]}"
