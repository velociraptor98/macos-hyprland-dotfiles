#!/usr/bin/env bash
# Month calendar popup under the date. Runs only when clicked: one `cal` call.
# Today is bracketed in place ("24[25]26") so the monospace grid stays aligned,
# and its week is drawn in the accent colour.

source "$CONFIG_DIR/colors.sh"

day="$(date +%d)"; day=$((10#$day))
dd="$(printf '%2d' "$day")"
if [ "$day" -lt 10 ]; then mark=" [$day]"; else mark="[$day]"; fi

title="$(date '+%B %Y')"
pad=$(( (22 - ${#title}) / 2 ))
args=(--set cal.0 label="$(printf '%*s%s' "$pad" '' "$title")")

i=0
while IFS= read -r line; do
  i=$((i + 1))
  [ "$i" = 1 ] && continue                       # cal's own header; we drew ours
  row="cal.$((i - 1))"
  if [ -z "${line// /}" ]; then
    args+=(--set "$row" drawing=off)
    continue
  fi
  padded=" $(printf '%-20s' "$line") "
  color=$FG
  [ "$i" = 2 ] && color=$COMMENT                  # weekday names
  if [ "$i" -gt 2 ] && [[ "$padded" == *" $dd "* ]]; then
    padded="${padded/ $dd /$mark}"
    color=$ACCENT
  fi
  args+=(--set "$row" drawing=on label="$padded" label.color=$color)
done <<EOF
$(cal)
EOF

# cal prints up to 6 week rows; hide any we didn't fill.
for ((j = i; j <= 7; j++)); do args+=(--set "cal.$j" drawing=off); done

sketchybar "${args[@]}" --set date popup.drawing=toggle
