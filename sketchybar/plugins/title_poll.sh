#!/usr/bin/env bash
# Window titles change without any event (browser tab switch, file save...).
# Every few seconds: one aerospace query, compared (as a checksum — titles are
# never written to disk) with what the controller last drew. Only if it differs
# is a redraw requested — otherwise nothing happens.

RUNDIR="${SKETCHYBAR_RUNDIR:-$(getconf DARWIN_USER_TEMP_DIR)sketchybar}"

now="$(aerospace list-windows --focused --format '%{window-id}|%{window-title}' 2>/dev/null)"
if [ -z "$now" ]; then
  now="none"
else
  now="$(printf '%s' "$now" | cksum)"
fi

last=""
[ -f "$RUNDIR/focused" ] && IFS= read -r last < "$RUNDIR/focused"

[ "$now" != "$last" ] && sketchybar --trigger aerospace_refresh
exit 0
