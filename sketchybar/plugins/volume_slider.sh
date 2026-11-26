#!/usr/bin/env bash
# Slider in the volume popup: click/drag sets the output volume.
# The volume_change event then refreshes the bar icon + label.

[ "$SENDER" = "mouse.clicked" ] || exit 0
# Only ever a plain 0-100 integer reaches AppleScript.
case "$PERCENTAGE" in '' | *[!0-9]*) exit 0 ;; esac
[ "$PERCENTAGE" -le 100 ] || exit 0
osascript -e "set volume output volume $PERCENTAGE" -e 'set volume output muted false'
