#!/usr/bin/env bash
# AeroSpace controller — draws the workspace pills (hyprland/workspaces) AND the
# focused-window title (hyprland/window) from one snapshot of AeroSpace state.
#
#   * 3 aerospace queries + 1 awk + at most 1 sketchybar call per redraw
#   * bursts of events (a switch fires ~4 within ~60ms) are coalesced: while a redraw
#     is running, new events just mark the state dirty and the running instance
#     redraws once more at the end, so the last redraw always sees the latest state.
#     (An extra wait before the first redraw was measured: no saving, only latency.)
#   * nothing is sent to sketchybar when the result is identical to the last redraw
#
# Pills: drawn on the bar of the display their workspace lives on; only occupied +
# on-screen workspaces are shown. Focused = wide accent capsule with app icons
# (the width change animates); on screen elsewhere = outlined, with app icons;
# everything else = a compact muted number, no fill. App icons need
# sketchybar-app-font (APP_ICONS=on); workspaces AeroSpace invents (e.g. "11")
# get a pill cloned on the fly.
# Title: only on the focused monitor's bar; left of the notch on the MacBook screen.
# Flourishes: the newly focused pill hops once; a changed title fades in.

source "$CONFIG_DIR/style.sh"   # colors, island, workspaces_bracket
source "$CONFIG_DIR/plugins/icon_map.sh"
source "$CONFIG_DIR/icons.sh"
set -f                          # app names / titles must never glob
umask 077                       # runtime files are private to this user

KNOWN=" 1 2 3 4 5 6 7 8 9 10 S "
RUNDIR="${SKETCHYBAR_RUNDIR:-$(getconf DARWIN_USER_TEMP_DIR)sketchybar}"
mkdir -m 700 -p "$RUNDIR"
LOCK="$RUNDIR/controller.lock"
DIRTY="$RUNDIR/controller.dirty"
# Only checksums are kept between runs — window titles never stay on disk.
LAST="$RUNDIR/controller.last"     # checksum of the last redraw (skip identical redraws)
FOCUSED="$RUNDIR/focused"          # checksum of "window-id|title" for title_poll.sh

render() {
  local ws_state="" win_state="" focused_id="" joined
  # The three queries run in parallel (~30ms instead of ~55ms sequentially).
  # name|display|monitor-name|visible|focused — every workspace that is occupied or on screen
  aerospace list-workspaces --all --format '%{workspace}|%{monitor-appkit-nsscreen-screens-id}|%{monitor-name}|%{workspace-is-visible}|%{workspace-is-focused}|%{workspace-root-container-layout}' > "$RUNDIR/q.ws" 2>/dev/null &
  aerospace list-windows --all --format '%{window-id}|%{workspace}|%{app-name}|%{window-title}' > "$RUNDIR/q.win" 2>/dev/null &
  aerospace list-windows --focused --format '%{window-id}|%{window-layout}' > "$RUNDIR/q.focus" 2>/dev/null &
  wait
  IFS= read -r -d '' ws_state   < "$RUNDIR/q.ws"
  IFS= read -r -d '' win_state  < "$RUNDIR/q.win"
  local focus_line="" win_layout=""
  IFS= read -r focus_line < "$RUNDIR/q.focus"
  rm -f "$RUNDIR/q.ws" "$RUNDIR/q.win" "$RUNDIR/q.focus"   # they hold every window title
  focused_id="${focus_line%%|*}"
  [ -n "$focus_line" ] && win_layout="${focus_line#*|}"
  ws_state="${ws_state%$'\n'}"; win_state="${win_state%$'\n'}"
  [ -z "$ws_state" ] && return   # AeroSpace busy/not running: keep the current bar

  # One pass: append each workspace's unique apps (tab-separated, in window order).
  joined="$(printf '%s\n@@\n%s\n' "$win_state" "$ws_state" | awk -F'|' '
    $0 == "@@" { part = 2; next }
    part != 2  { if (NF >= 3 && !seen[$2 SUBSEP $3]++) apps[$2] = apps[$2] (apps[$2] == "" ? "" : "\t") $3; next }
    NF >= 6    { print $1 "|" $2 "|" $3 "|" $4 "|" $5 "|" $6 "|" apps[$1] }')"

  local args=() shown=" " new_items=0
  local ws display mon visible focused apps app icons bg fg border pad item expand
  local f_display="" f_mon="" f_layout="" f_ws="" root_layout

  while IFS='|' read -r ws display mon visible focused root_layout apps; do
    [ -z "$ws" ] && continue
    shown="$shown$ws "
    item="workspace.$ws"

    case "$KNOWN" in
      *" $ws "*) ;;
      *[!A-Za-z0-9_-]*) continue ;;   # odd name: no pill (it would end up in a click_script)
      *) if ! sketchybar --query "$item" >/dev/null 2>&1; then
           sketchybar --clone "$item" workspace.10 \
                      --set "$item" icon="$ws" click_script="aerospace workspace '$ws'" \
                      --move "$item" before workspace.S
           new_items=1
         fi ;;
    esac

    icons=""
    if [ "$APP_ICONS" = "on" ] && [ -n "$apps" ]; then
      local old_ifs="$IFS"; IFS=$'\t'
      for app in $apps; do icon_map "$app"; icons="$icons$APP_ICON "; done
      IFS="$old_ifs"
      icons="${icons% }"
    fi

    if [ "$focused" = "true" ]; then
      bg=$WS_ACTIVE_BG; fg=$WS_ACTIVE_FG; border=$WS_ACTIVE_BG; pad=16; expand=1
      f_display="$display"; f_mon="$mon"; f_layout="$root_layout"; f_ws="$ws"
    elif [ "$visible" = "true" ]; then
      bg=$WS_VISIBLE_BG; fg=$WS_VISIBLE_FG; border=$WS_VISIBLE_BORDER; pad=12; expand=1
    else
      bg=$WS_INACTIVE_BG; fg=$WS_INACTIVE_FG; border=$WS_INACTIVE_BG; pad=7; expand=0
    fi

    args+=(--set "$item" drawing=on display="$display"
      background.color=$bg background.border_color=$border
      icon.color=$fg label.color=$fg icon.padding_left=$pad)
    if [ -n "$icons" ] && [ "$expand" = 1 ]; then
      args+=(icon.padding_right=6 label="$icons" label.drawing=on label.padding_right=$pad)
    else
      args+=(icon.padding_right=$pad label.drawing=off)
    fi
  done <<EOF
$joined
EOF

  [ "$new_items" = 1 ] && workspaces_bracket

  # Hide every known pill AeroSpace didn't list (empty + off screen).
  for ws in $KNOWN; do
    case "$shown" in *" $ws "*) ;; *) args+=(--set "workspace.$ws" drawing=off) ;; esac
  done

  # ── Layout indicator (focused monitor only) ─────────────────────────────
  # The focused window's container layout if there is one, else the workspace root's.
  local layout="${win_layout:-$f_layout}" layout_icon
  case "$layout" in
    h_tiles)     layout_icon=$ICON_LAYOUT_H ;;
    v_tiles)     layout_icon=$ICON_LAYOUT_V ;;
    *accordion)  layout_icon=$ICON_LAYOUT_ACCORDION ;;
    floating)    layout_icon=$ICON_LAYOUT_FLOAT ;;
    *)           layout_icon="" ;;
  esac
  if [ -n "$layout_icon" ] && [ -n "$f_display" ]; then
    args+=(--set layout drawing=on display="$f_display" icon="$layout_icon")
  else
    args+=(--set layout drawing=off)
  fi

  # ── Focused window title ──────────────────────────────────────────────────
  local line="" title="" max=60
  if [ -n "$focused_id" ]; then
    line="$(printf '%s\n' "$win_state" | awk -F'|' -v id="$focused_id" '$1 == id { print; exit }')"
  fi
  local shown_sig="none"
  if [ -z "$line" ]; then
    args+=(--set front_app drawing=off)
    printf 'none' > "$FOCUSED"
  else
    app="${line#*|*|}"; app="${app%%|*}"     # field 3
    title="${line#*|*|*|}"                   # field 4+ (titles may contain '|')
    printf '%s|%s' "$focused_id" "$title" | cksum > "$FOCUSED"

    [ -z "$title" ] && title="$app"
    title="${title% — $app}"; title="${title% - $app}"   # the icon already says it

    case "$f_mon" in
      [Bb]uilt-in*) args+=(--set front_app display="$f_display" position=left padding_left=8); max=24 ;;  # notch
      ?*)           args+=(--set front_app display="$f_display" position=center padding_left=0) ;;
    esac
    [ "${#title}" -gt "$max" ] && title="${title:0:$((max - 1))}…"

    if [ "$APP_ICONS" = "on" ]; then
      icon_map "$app"
      args+=(--set front_app drawing=on icon="$APP_ICON" label="$title")
    else
      args+=(--set front_app drawing=on label="$app  ·  $title")
    fi
    shown_sig="$(printf '%s|%s' "$app" "$title" | cksum)"   # checksum only: titles never hit disk
  fi

  # ── Apply (skip if nothing changed) ───────────────────────────────────────
  local sig prev=""
  sig="$(printf '%s\037' "${args[@]}" | cksum)"
  [ -f "$LAST" ] && IFS= read -r prev < "$LAST"
  if [ "$new_items" = 0 ] && [ "$sig" = "$prev" ]; then
    return
  fi
  printf '%s\n' "$sig" > "$LAST"

  # Title fade-in: if what the title shows changed, start it transparent and
  # let the animated update below bring it to full colour.
  local pre=() post=() prev_shown="" prev_ws=""
  [ -f "$RUNDIR/title.shown" ] && IFS= read -r prev_shown < "$RUNDIR/title.shown"
  if [ "$shown_sig" != "none" ] && [ "$shown_sig" != "$prev_shown" ]; then
    pre=(--set front_app label.color="0x00${FG#0xff}" icon.color="0x00${ACCENT#0xff}")
    post=(--set front_app label.color=$FG icon.color=$ACCENT)
  fi
  printf '%s\n' "$shown_sig" > "$RUNDIR/title.shown"

  sketchybar "${pre[@]}" --animate tanh 15 "${args[@]}" "${post[@]}"

  # Workspace hop: the newly focused pill jumps 3px and settles (one-off).
  [ -f "$RUNDIR/focused.ws" ] && IFS= read -r prev_ws < "$RUNDIR/focused.ws"
  if [ -n "$f_ws" ] && [ "$f_ws" != "$prev_ws" ]; then
    printf '%s\n' "$f_ws" > "$RUNDIR/focused.ws"
    sketchybar --animate sin 7 --set "workspace.$f_ws" y_offset=3 y_offset=0
  fi
}

# ── Coalescing lock ─────────────────────────────────────────────────────────
touch "$DIRTY"
# A lock older than 10s belongs to a run that died; clear it.
if [ -d "$LOCK" ] && [ $(( $(date +%s) - $(stat -f %m "$LOCK") )) -gt 10 ]; then
  rmdir "$LOCK" 2>/dev/null
fi
while :; do
  mkdir "$LOCK" 2>/dev/null || exit 0      # the running instance will pick up DIRTY
  trap 'rmdir "$LOCK" 2>/dev/null' EXIT
  while [ -e "$DIRTY" ]; do
    rm -f "$DIRTY"
    render
  done
  rmdir "$LOCK"
  trap - EXIT
  [ -e "$DIRTY" ] || break                 # an event slipped in while unlocking
done
