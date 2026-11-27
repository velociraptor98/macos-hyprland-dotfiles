#!/usr/bin/env bash
# Month calendar popup under the date. Runs only when clicked: one `cal` call.
# Columns are two spaces apart so today's accent ring has room. Today's row is
# split: the days before today sit in the icon, and the label starts at today's
# digits with a fixed 20px width, so the label's round background circles today's
# number only (see the cal.* rows in sketchybarrc).

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/plugins/popup.sh"

CHAR=8          # JetBrainsMono advance at 13pt is 7.8pt
RING=20         # ring diameter (label.width + background height/radius in sketchybarrc)
WIDTH=28        # characters per row: 7 two-char days, 2-space gaps, 1 space each side

day="$(date +%d)"; day=$((10#$day))

title="$(date '+%B %Y')"
pad=$(( (WIDTH - ${#title}) / 2 ))
args=(--set cal.0 label.background.drawing=off label="$(printf '%*s%s' "$pad" '' "$title")")

# Plain row: whole week in the label, no ring.
plain=(icon.drawing=off label.padding_left=12 label.width=dynamic label.background.drawing=off)

i=0
while IFS= read -r line; do
  i=$((i + 1))
  [ "$i" = 1 ] && continue                       # cal's own header; we drew ours
  row="cal.$((i - 1))"
  if [ -z "${line// /}" ]; then
    args+=(--set "$row" drawing=off)
    continue
  fi
  # cal's columns are 3 chars wide (2-char day + 1 space); re-space them to 4.
  padded=" "
  for c in 0 1 2 3 4 5 6; do
    cell="${line:$((c * 3)):2}"
    padded+="$(printf '%2s' "$cell")"
    [ "$c" -lt 6 ] && padded+="  "
  done
  padded+=" "
  color=$FG
  [ "$i" = 2 ] && color=$COMMENT                  # weekday names

  if [ "$i" -gt 2 ] && [[ "$padded" == *" $day "* ]]; then
    before="${padded%%" $day "*} "                # everything up to today's digits
    stripped="${before%"${before##*[! ]}"}"       # ...without the gap before them
    gap=$(( ${#before} - ${#stripped} ))          # spaces between previous day and today
    rest="${padded:${#before}}"                   # today's digits onwards
    xoff=$(( ${#day} * CHAR / 2 - RING / 2 ))     # centre the ring on the digits
    if [ -n "$stripped" ]; then
      args+=(--set "$row" drawing=on icon.drawing=on icon="$stripped"
        icon.padding_right=$(( gap * CHAR )) label.padding_left=0)
    else                                          # today is in the first column
      args+=(--set "$row" drawing=on icon.drawing=off label.padding_left=$(( 12 + gap * CHAR )))
    fi
    args+=(label="$rest" label.color=$color label.width=$RING
      label.background.drawing=on label.background.x_offset=$xoff)
  else
    args+=(--set "$row" drawing=on "${plain[@]}" label="$padded" label.color=$color)
  fi
done <<EOF2
$(cal)
EOF2

# cal prints up to 6 week rows; hide any we didn't fill.
for ((j = i; j <= 7; j++)); do args+=(--set "cal.$j" drawing=off); done

sketchybar "${args[@]}"
island_popup_toggle clock_island "cal.0 cal.1 cal.2 cal.3 cal.4 cal.5 cal.6 cal.7 cal.open" "" 250
