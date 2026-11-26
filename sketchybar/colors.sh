#!/usr/bin/env bash
# Tokyo Night palette (https://github.com/folke/tokyonight.nvim) as 0xAARRGGBB

export BLACK=0xff15161e
export BG=0xe61a1b26          # bar islands (90% opaque, like a blurred Waybar)
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

# Semantic
export ACCENT=$BLUE
export WS_ACTIVE_BG=$BLUE
export WS_ACTIVE_FG=$BG_SOLID
export WS_INACTIVE_BG=$BG_HIGHLIGHT
export WS_INACTIVE_FG=$FG_DARK
export WS_HOVER_BG=$BORDER
export WS_VISIBLE_FG=$BLUE        # on screen on the other monitor, not focused
export WS_VISIBLE_BORDER=$BLUE
