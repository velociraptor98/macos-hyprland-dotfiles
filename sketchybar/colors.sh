#!/usr/bin/env bash
# Tokyo Night palette (https://github.com/folke/tokyonight.nvim) as 0xAARRGGBB

export BLACK=0xff15161e
export BG=0xd91a1b26          # bar islands (85% opaque)
export BG_HOVER=0xe6292e42    # island under the mouse
export BG_FLASH=0xd9414868    # brief flash when an island is clicked
export BG_POPUP=0xd91a1b26    # popups (85%, frosted by popup.blur_radius)
export BG_SOLID=0xff1a1b26
export BG_HIGHLIGHT=0xff292e42
export BORDER=0xff414868
export COMMENT=0xff565f89
export FG=0xffc0caf5
export FG_DARK=0xffa9b1d6

export BLUE=0xff7aa2f7
export CYAN=0xff7dcfff
export TEAL=0xff73daca
export GREEN=0xff9ece6a
export YELLOW=0xffe0af68
export ORANGE=0xffff9e64
export RED=0xfff7768e
export MAGENTA=0xffbb9af7
export PURPLE=0xff9d7cd8

export TRANSPARENT=0x00000000

# Glass look: hairline light edge + soft shadow under each island
export EDGE=0x14c0caf5        # FG at 8%: barely-there rim
export EDGE_HOVER=0x40c0caf5  # FG at 25%
export SHADOW=0x66000000      # black at 40%
export DIVIDER=0x1fc0caf5     # FG at 12%: separators inside an island
export ALERT_EDGE=0xccf7768e  # RED at 80%: status island edge while something is critical

# Semantic
export ACCENT=$BLUE
export WS_ACTIVE_BG=$BLUE
export WS_ACTIVE_FG=$BG_SOLID
export WS_INACTIVE_BG=$TRANSPARENT     # only the focused pill gets a fill
export WS_INACTIVE_FG=$FG_DARK
export WS_HOVER_BG=$BG_HIGHLIGHT
export WS_VISIBLE_BG=$BG_HIGHLIGHT  # on screen on the other monitor, not focused
export WS_VISIBLE_FG=$FG
export WS_VISIBLE_BORDER=$BG_HIGHLIGHT

# Status icons are monochrome; colour only means something (warning, charging, muted).
export ICON_DIM=$FG_DARK
