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

- Floating glass islands: translucent capsules with a hairline edge and a soft shadow; each lights up on hover
  and flashes on click
- Small one-off animations, nothing looping: the bar slides in on start/reload, the newly focused workspace pill
  hops, a changed window title fades in, the mode pill pops in and out
- Workspaces show only occupied + on-screen ones, drawn on their own monitor's bar. The focused one is a wide
  accent pill with app icons (the width change animates), the one on screen on the other monitor is outlined,
  the rest are compact muted numbers
- Focused window title (left of the notch on a MacBook screen), layout indicator, AeroSpace mode pill with key hints
- Click popups (frosted): power menu (logo; grouped into Apps / Session / Reload), calendar with today ringed (date/time),
  battery details, volume slider (right click = mute). The battery and volume popups hang from the status island at
  its full width; the calendar lines up with the clock island
- One status island: CPU with a live usage graph, temperature and memory │ Wi-Fi, volume and battery — plus a clock island
- Coloured icons, quieter labels; warning colours on CPU, temperature, memory and battery as they climb. The status
  island's edge turns red while something is critical (battery under 20% off the charger, CPU ≥ 85 °C, memory ≥ 85%)
- Event-driven: one controller script redraws from a single AeroSpace snapshot, bursts are coalesced,
  identical redraws are skipped, no window titles are written to disk. The only polling is cheap
  (window title every 5s, CPU/temperature every 5s, the rest slower); nothing needs extra macOS permissions

## Prerequisites

| Tool | Needed for | Required? | Tested with |
|---|---|---|---|
| [Homebrew](https://brew.sh) | installing everything below | yes | — |
| [AeroSpace](https://github.com/nikitabobko/AeroSpace) | tiling window manager (the "Hyprland" part) | yes | 0.21.3-Beta |
| [SketchyBar](https://github.com/FelixKratz/SketchyBar) | the status bar (the "Waybar" part) | yes | 2.24.1 |
| [JetBrainsMono Nerd Font](https://www.nerdfonts.com) | bar icons (any Nerd Font v3 works) | yes | 3.x |
| [sketchybar-app-font](https://github.com/kvndrsslr/sketchybar-app-font) | per-app icons in workspaces and the title | optional — without it, workspaces show numbers only | — |
| [JankyBorders](https://github.com/FelixKratz/JankyBorders) | Hyprland-style window borders | optional | 1.9.0 |
| Xcode Command Line Tools (`xcode-select --install`) | CPU temperature: the bar compiles a tiny sensor reader on first run | optional — without it the temperature is hidden | Apple M5 |

Install them:

```sh
# Window manager
brew install --cask nikitabobko/tap/aerospace

# Status bar
brew install FelixKratz/formulae/sketchybar

# Fonts
brew install --cask font-jetbrains-mono-nerd-font
brew install --cask font-sketchybar-app-font      # optional

# Window borders
brew install FelixKratz/formulae/borders          # optional
```

**SketchyBar:** follow the official [SketchyBar setup guide](https://felixkratz.github.io/SketchyBar/setup)
from the [main repo](https://github.com/FelixKratz/SketchyBar) for installing and running SketchyBar and for
any macOS-version-specific steps. **Skip its step that copies the example `sketchybarrc` and plugins into
`~/.config/sketchybar`** — this repo provides that folder (see [Install](#install)).

Recommended: set the macOS menu bar to auto-hide (System Settings → Control Center →
Automatically hide and show the menu bar), so SketchyBar takes its place like Waybar.

## Install

```sh
git clone <this repo> ~/dotfiles/macos-hyprland && cd ~/dotfiles/macos-hyprland
# Move any existing ~/.config/sketchybar out of the way first, or the link lands inside it.
mkdir -p ~/.config/borders
ln -sf "$PWD/aerospace/aerospace.toml" ~/.aerospace.toml
ln -sfn "$PWD/sketchybar" ~/.config/sketchybar
ln -sf "$PWD/borders/bordersrc" ~/.config/borders/bordersrc

brew services start sketchybar
brew services start borders      # only if you installed JankyBorders
```

Then start AeroSpace (it reloads its config on save; SketchyBar hot-reloads too).

## Customise

- **Terminal:** `alt-q` / `alt-enter` open a new window of `TERMINAL_APP`, set once under `[exec.env-vars]`
  at the bottom of `aerospace/aerospace.toml` (any app where ⌘N opens a window: Terminal, Ghostty, iTerm…).
  The first use asks macOS for Accessibility permission (it sends ⌘N).
- **Launcher:** `alt-r` and the power menu open macOS *Apps* (macOS 26+) — change `open -a Apps` if you use Raycast/Alfred.
- **Homebrew prefix:** works on Apple Silicon (`/opt/homebrew`) and Intel (`/usr/local`) — no absolute paths to edit.
- **Monitors:** workspaces 1–5 go to the external display, 6–10 to the built-in one (`[workspace-to-monitor-force-assignment]`).
- **App → workspace:** browsers (Safari, Helium) open on 1; terminals and coding agents (Terminal, Rex, Claude, OpenCode)
  on 2; Finder, small utilities and picture-in-picture video float. Edit the `[[on-window-detected]]` rules in `aerospace/aerospace.toml`
  (find an app's ID with `aerospace list-apps`).
- **Colours:** `sketchybar/colors.sh` and `borders/bordersrc`. Island transparency is the alpha byte of `BG`
  in `colors.sh` (`0xbf…` = 75%); edge, shadow and hover colours sit next to it.
- **App icons:** `sketchybar/plugins/icon_map.sh` (unknown apps get a generic icon).

## Key bindings (main)

| Keys | Action |
|---|---|
| `alt-q` / `alt-enter` `alt-e` `alt-r` | Terminal, file manager (Finder), launcher (Apps) |
| `alt-1…0` / `alt-shift-1…0` | Workspace / move window there (follow) |
| `alt-ctrl-1…0` | Move window silently |
| `alt-[ ]` / `alt-shift-[ ]` | Previous / next workspace, or take the window there (wraps around) |
| `alt-tab` | Back to the previous workspace |
| `alt-h j k l` / `alt-shift-h j k l` | Focus / move (crosses monitors; arrow keys work too) |
| `alt-ctrl-h j k l` `alt-- =` `alt-b` | Resize, smart shrink / grow, balance sizes |
| `alt-, .` / `alt-shift-, .` | Focus / move window to previous / next monitor |
| `alt-c` `alt-v` `alt-f` / `alt-shift-f` | Close, float, fullscreen edge to edge / fullscreen inside the gaps |
| `alt-t` `alt-w` `alt-/` | Split orientation, accordion, tiles orientation |
| `alt-s` / `alt-shift-s` | Scratchpad toggle / send window to it |
| `alt-shift-r` / `alt-shift-;` | Resize mode / service mode (the bar shows their keys) |

In resize mode: `h j k l` resize by 50, `shift-h j k l` by 200, `- =` smart, `b` balance and exit, `esc` exit.
