#!/usr/bin/env bash
# Bar background, drawn per display.
# The bar window itself stays transparent: sketchybar's bar colour is global, but a
# notched screen needs a break in the middle. So each display gets glass strips:
#   plain screen   one strip, full width
#   notched screen two strips, from the edges to just short of the notch
# A strip is a zero-width item (it takes no room, so modules lay out as usual)
# whose label is as wide as the strip; the label's background is the glass.
# Runs at start and on display_change; skips the rebuild if no screen changed.

source "$CONFIG_DIR/colors.sh"

RUNDIR="${SKETCHYBAR_RUNDIR:-$(getconf DARWIN_USER_TEMP_DIR)sketchybar}"
LAST="$RUNDIR/bar_bg.last"
MARGIN=10       # = bar margin in sketchybarrc
NOTCH_GAP=8     # space between a strip's rounded end and the notch
INSET=4         # first module sits this far inside the strip

# One line per screen, in NSScreen order (= sketchybar's display id):
#   <id> <width> <left of notch> <right of notch>     (notch widths 0 if none)
geometry="$(osascript -l JavaScript -e '
  ObjC.import("AppKit");
  var s = $.NSScreen.screens, out = [];
  for (var i = 0; i < s.count; i++) {
    var sc = s.objectAtIndex(i), l = sc.auxiliaryTopLeftArea, r = sc.auxiliaryTopRightArea;
    out.push((i + 1) + " " + Math.floor(sc.frame.size.width) + " " +
             Math.floor(l ? l.size.width : 0) + " " + Math.floor(r ? r.size.width : 0));
  }
  out.join("\n")' 2>/dev/null)"
[ -z "$geometry" ] && exit 0

mkdir -m 700 -p "$RUNDIR"
[ -f "$LAST" ] && [ "$(cat "$LAST")" = "$geometry" ] && exit 0
printf '%s' "$geometry" > "$LAST"

glass=(
  icon.drawing=off
  label=" "
  label.padding_left=0
  label.padding_right=0
  label.background.color=$BG
  label.background.border_color=$EDGE
  label.background.border_width=1
  label.background.corner_radius=16
  label.background.height=32
)

args=(--remove '/barbg\..*/')
strip() { # name position display width
  args+=(--add item "$1" "$2"
         --set "$1" "${glass[@]}" display="$3" width=0 label.width="$4")
  # Drawn first (under the modules): left strips lead the item list, right strips
  # become the outermost right item. The inset pads the module side.
  if [ "$2" = left ]; then
    args+=(padding_left=0 padding_right=$INSET --move "$1" before logo)
  else
    args+=(padding_right=0 padding_left=$INSET --move "$1" before clock)
  fi
}

while read -r id width left right; do
  [ -z "$id" ] && continue
  if [ "${left:-0}" -gt 0 ] && [ "${right:-0}" -gt 0 ]; then
    strip "barbg.$id.l" left  "$id" $((left - MARGIN - NOTCH_GAP))
    strip "barbg.$id.r" right "$id" $((right - MARGIN - NOTCH_GAP))
  else
    strip "barbg.$id" left "$id" $((width - 2 * MARGIN))
  fi
done <<EOF
$geometry
EOF

sketchybar "${args[@]}"
