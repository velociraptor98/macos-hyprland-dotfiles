#!/usr/bin/env bash
# Total CPU usage, normalised to 0-100% across all cores, plus a sparkline
# (cpu.graph) of the last ~3 minutes, coloured by the current load.

source "$CONFIG_DIR/plugins/hover.sh"   # mouse enter/leave: highlight island, exit
[ "$SENDER" = "mouse.clicked" ] && exit 0   # flash done; click_script opens the app

source "$CONFIG_DIR/colors.sh"

ncpu="${NCPU:-$(sysctl -n hw.ncpu)}"   # passed in by sketchybarrc
read -r usage frac <<EOF
$(ps -A -o %cpu= | awk -v n="$ncpu" '{ s += $1 } END { v = s / n; if (v > 100) v = 100; printf "%d %.2f", v, v / 100 }')
EOF

if [ "$usage" -ge 80 ]; then color=$RED
elif [ "$usage" -ge 50 ]; then color=$YELLOW
else color=$BLUE
fi

fill="0x40${color#0xff}"   # same colour at 25% under the line
sketchybar --set "$NAME" icon.color=$color label="${usage}%" \
           --set cpu.graph graph.color=$color graph.fill_color=$fill \
           --push cpu.graph "$frac"
