# Quickshell Config

A [Quickshell](https://quickshell.outfoxxed.me/) desktop shell for a Wayland session running the [Niri](https://github.com/YaLTeR/niri) scrolling compositor. Provides a topbar, a live wallpaper window, and desktop notification popups, all written in QML.

![Quickshell](../screenshots/quickshell.png)

## Features

- **Topbar** (`windows/Topbar.qml`) — a `wlr-layer-shell` panel anchored to the top of the screen with:
  - Niri workspaces indicator and active window title (left)
  - CPU/memory usage, volume, network, and battery status (right)
  - Clipboard history, system tray, clock, and screen recorder widgets available but currently disabled (commented out) — re-enable by uncommenting the relevant lines in `Topbar.qml`
- **Wallpaper** (`windows/Wallpaper.qml`) — a background layer-shell window rendering a clock plus layered background images (`images/forest.png`, `images/chowy_front.png`)
- **Notifications** (`windows/Notifications.qml`) — a minimal notification popup daemon (via `Quickshell.Services.Notifications`), one panel per screen, anchored top-right

## Requirements

- [Quickshell](https://quickshell.outfoxxed.me/) (Qt6/QML runtime)
- [Niri](https://github.com/YaLTeR/niri) — workspace/window state is read via `niri msg --json event-stream`
- A Nerd Font (`SFMono Nerd Font` by default, see `config/Fonts.qml`) for icon glyphs
- [`cliphist`](https://github.com/sentriz/cliphist) — clipboard history (`services/ClipboardService.qml`)
- PipeWire (`Quickshell.Services.Pipewire`) — volume widget
- UPower (`Quickshell.Services.UPower`) — battery widget
- NetworkManager (`Quickshell.Networking`) — network widget
- `wf-recorder` + `slurp` — optional screen recording widget (disabled by default)

## Directory structure

```
shell.qml               Entry point — loads the topbar, wallpaper, and notification windows
windows/                 Top-level PanelWindows (Topbar, Wallpaper, Notifications)
widgets/                 Individual topbar widgets (Battery, Volume, Network, Clock, Workspaces, ...)
services/                Singleton state/services backed by shell processes (Niri, Clipboard, SystemResources)
components/              Reusable UI pieces (Popup, MyTooltip, TextInfoReveal)
config/                  Singletons for theming — Fonts.qml (colors/typography), Icons.qml (icon/image paths)
utilities/               Setting.qml — persisted user settings (Qt.labs.settings), Utilities.qml
icons/                   SVG icons used by widgets
images/                  Wallpaper images
scripts/node/            Auxiliary scripts (e.g. niri.js)
```

## Configuration

- **Colors & fonts**: edit `config/Fonts.qml` (font family/sizes and the color palette used across all widgets).
- **Icon/image paths**: `config/Icons.qml` resolves paths under `icons/` and `images/` relative to the shell directory.
- **Persisted settings**: `utilities/Setting.qml` stores user-adjustable font sizes via `Qt.labs.settings`.
- **Enabling/disabling widgets**: toggle widgets in the topbar by commenting/uncommenting entries in `windows/Topbar.qml`.

## Running

This directory is expected to live at (or be symlinked to) `~/.config/quickshell`. Launch it with:

```sh
qs -c quickshell
```

or, if run directly from this path:

```sh
quickshell -p shell.qml
```

## Notes

- `widgets/Hyprland.qml` and `widgets/HyprlandActiveClient.qml` are legacy/alternate widgets for a Hyprland session and are not wired into the current Niri-based `Topbar.qml`.
- `NiriService` and `ClipboardService` shell out to `niri` and `cliphist` respectively; both must be installed and on `PATH` for their widgets to function.
