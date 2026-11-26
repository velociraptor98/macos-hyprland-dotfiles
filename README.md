# macOS Hyprland-style setup

A Hyprland / Waybar look and feel on macOS: **AeroSpace** (tiling), **SketchyBar** (Waybar-style
bar) and **JankyBorders** (window borders), themed **Tokyo Night**.

## What's in here

| Path | Goes to | What it is |
|---|---|---|
| `aerospace/aerospace.toml` | `~/.aerospace.toml` | Hyprland-style bindings (`alt` = SUPER), gaps, workspaces pinned to monitors, bar events |
| `sketchybar/` | `~/.config/sketchybar/` | The bar: floating islands, per-monitor workspaces, window title, popups |
| `borders/bordersrc` | `~/.config/borders/bordersrc` | Blue → magenta active border, muted inactive |

## Bar features

- Workspaces show only occupied + on-screen ones, each with app icons, drawn on their own monitor's bar
- Focused window title (left of the notch on a MacBook screen), layout indicator, AeroSpace mode pill with key hints
- Click popups: power menu (logo), calendar (date/time), battery details, volume slider (right click = mute)
- CPU, memory, Wi-Fi, volume, battery, clock
- Event-driven: one controller script redraws from a single AeroSpace snapshot, bursts are coalesced,
  identical redraws are skipped, no window titles are written to disk

## Requirements

```sh
brew install --cask nikitabobko/tap/aerospace
brew install FelixKratz/formulae/sketchybar FelixKratz/formulae/borders
brew install --cask font-jetbrains-mono-nerd-font font-sketchybar-app-font
```

Recommended: macOS menu bar set to auto-hide (System Settings → Control Center → Automatically hide and show the menu bar).

## Install

```sh
git clone <this repo> ~/dotfiles/macos-hyprland && cd ~/dotfiles/macos-hyprland
ln -sf "$PWD/aerospace/aerospace.toml" ~/.aerospace.toml
ln -sfn "$PWD/sketchybar" ~/.config/sketchybar
mkdir -p ~/.config/borders && ln -sf "$PWD/borders/bordersrc" ~/.config/borders/bordersrc

brew services start sketchybar
brew services start borders
```

Then start AeroSpace (it reloads its config on save; SketchyBar hot-reloads too).

## Customise

- **Terminal:** `alt-q` / `alt-enter` open a new window of `TERMINAL_APP`, set once under `[exec.env-vars]`
  at the bottom of `aerospace/aerospace.toml` (any app where ⌘N opens a window: Terminal, Ghostty, iTerm…).
  The first use asks macOS for Accessibility permission (it sends ⌘N).
- **Launcher:** `alt-r` and the power menu open macOS *Apps* (macOS 26+) — change `open -a Apps` if you use Raycast/Alfred.
- **Homebrew prefix:** works on Apple Silicon (`/opt/homebrew`) and Intel (`/usr/local`) — no absolute paths to edit.
- **Monitors:** workspaces 1–5 go to the external display, 6–10 to the built-in one (`[workspace-to-monitor-force-assignment]`).
- **Colours:** `sketchybar/colors.sh` and `borders/bordersrc`.
- **App icons:** `sketchybar/plugins/icon_map.sh` (unknown apps get a generic icon).

## Key bindings (main)

| Keys | Action |
|---|---|
| `alt-1…0` / `alt-shift-1…0` | Workspace / move window there (follow) |
| `alt-ctrl-1…0` | Move window silently |
| `alt-h j k l` / `alt-shift-h j k l` | Focus / move (crosses monitors) |
| `alt-, .` / `alt-shift-, .` | Focus / move window to previous / next monitor |
| `alt-c` `alt-v` `alt-f` | Close, float, fullscreen |
| `alt-t` `alt-w` `alt-/` | Split orientation, accordion, tiles orientation |
| `alt-s` / `alt-shift-s` | Scratchpad toggle / send window to it |
| `alt-shift-r` / `alt-shift-;` | Resize mode / service mode |
