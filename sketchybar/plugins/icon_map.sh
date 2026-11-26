#!/usr/bin/env bash
# App name -> sketchybar-app-font ligature.
# https://github.com/kvndrsslr/sketchybar-app-font
# Sets $APP_ICON (no subshell, so it's cheap to call in a loop).
# The upstream project ships a much bigger icon_map.sh; unknown apps fall back to :default:.

icon_map() {
  case "$1" in
    "Rex" | "Terminal" | "cmux") APP_ICON=":terminal:" ;;
    "Ghostty") APP_ICON=":ghostty:" ;;
    "kitty") APP_ICON=":kitty:" ;;
    "WezTerm") APP_ICON=":wezterm:" ;;
    "Alacritty") APP_ICON=":alacritty:" ;;
    "Safari" | "Safari Technology Preview") APP_ICON=":safari:" ;;
    "Google Chrome" | "Google Chrome Canary") APP_ICON=":google_chrome:" ;;
    "Helium" | "Chromium") APP_ICON=":chromium:" ;;
    "Firefox" | "Firefox Developer Edition" | "Zen" | "Zen Browser") APP_ICON=":firefox:" ;;
    "Arc") APP_ICON=":arc:" ;;
    "Zed" | "Zed Preview") APP_ICON=":zed:" ;;
    "Code" | "Visual Studio Code") APP_ICON=":code:" ;;
    "Cursor") APP_ICON=":cursor:" ;;
    "Xcode") APP_ICON=":xcode:" ;;
    "Obsidian") APP_ICON=":obsidian:" ;;
    "Notion") APP_ICON=":notion:" ;;
    "Claude") APP_ICON=":claude:" ;;
    "Finder") APP_ICON=":finder:" ;;
    "System Settings" | "System Preferences") APP_ICON=":gear:" ;;
    "App Store") APP_ICON=":app_store:" ;;
    "1Password" | "1Password 7") APP_ICON=":one_password:" ;;
    "Steam" | "Steam Helper") APP_ICON=":steam:" ;;
    "Unity" | "Unity Hub") APP_ICON=":unity:" ;;
    "Mail" | "HEY") APP_ICON=":mail:" ;;
    "Messages") APP_ICON=":messages:" ;;
    "Calendar") APP_ICON=":calendar:" ;;
    "Notes") APP_ICON=":notes:" ;;
    "Calculator") APP_ICON=":calculator:" ;;
    "Preview") APP_ICON=":pdf:" ;;
    "Music") APP_ICON=":music:" ;;
    "Spotify") APP_ICON=":spotify:" ;;
    "Slack") APP_ICON=":slack:" ;;
    "Discord") APP_ICON=":discord:" ;;
    "Telegram") APP_ICON=":telegram:" ;;
    "WhatsApp") APP_ICON=":whats_app:" ;;
    "zoom.us") APP_ICON=":zoom:" ;;
    "Figma") APP_ICON=":figma:" ;;
    *) APP_ICON=":default:" ;;
  esac
}
