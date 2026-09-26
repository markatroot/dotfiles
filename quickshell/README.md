# Quickshell Config

A [Quickshell](https://quickshell.outfoxxed.me/) desktop shell for a Wayland session running the [Niri](https://github.com/YaLTeR/niri) scrolling compositor. Provides a topbar, a live wallpaper window, desktop notification popups, and a keyboard-driven clipboard history popup, all written in QML. A separate standalone app launcher shell lives in `shells/launcher/`.

![Quickshell](../screenshots/quickshell.png)

## Features

- **Topbar** (`windows/Topbar.qml`) — a `wlr-layer-shell` panel anchored to the top of the screen with:
  - Niri workspaces indicator and active window title (left)
  - CPU/memory usage, clipboard history, volume, network, and battery status (right)
  - System tray, clock, and screen recorder widgets available but currently disabled (commented out) — re-enable by uncommenting the relevant lines in `Topbar.qml`
- **Clipboard history** (`widgets/Clipboard.qml`) — clicking the topbar icon (or the `clipboard` IPC target, see below) opens a searchable `cliphist` popup as a top-right overlay layer-shell window; arrow keys/Tab to navigate, Enter to copy, Esc to close, "Clear" to wipe history
- **Wallpaper** (`windows/Wallpaper.qml`) — a background layer-shell window (namespace `quickshell:my-wallpaper`) rendering a large date/time clock (`widgets/Clock.qml`) plus layered background images (`images/forest.png`, `images/chowy_front.png`)
- **Notifications** (`windows/Notifications.qml`) — a minimal notification popup daemon (via `Quickshell.Services.Notifications`), one panel per screen, anchored top-right; supports images/app icons, body markup, and action buttons, auto-dismisses after the notification's timeout (6s default), and dismisses on click or ✕. Its colors are set as tunables at the top of the file rather than from `config/Fonts.qml`
- **App launcher** (`shells/launcher/shell.qml`) — a separate, self-contained Quickshell config (not loaded by `shell.qml`): a centered fuzzy-search launcher over desktop entries, toggled via the `launcher` IPC target

## Requirements

- [Quickshell](https://quickshell.outfoxxed.me/) (Qt6/QML runtime)
- [Niri](https://github.com/YaLTeR/niri) — workspace/window state is read via `niri msg --json event-stream`
- A Nerd Font (`SFMono Nerd Font` by default, see `config/Fonts.qml`) for icon glyphs
- [`cliphist`](https://github.com/sentriz/cliphist) + `wl-clipboard` (`wl-copy`) — clipboard history (`services/ClipboardService.qml`)
- PipeWire (`Quickshell.Services.Pipewire`) — volume widget
- UPower (`Quickshell.Services.UPower`) — battery widget
- NetworkManager (`Quickshell.Networking`) — network widget
- `wf-recorder` + `slurp` — optional screen recording widget (disabled by default)

## Directory structure

```
shell.qml               Entry point — loads the topbar, wallpaper, and notification windows
shells/launcher/         Standalone app launcher config (separate shell.qml, run on its own)
windows/                 Top-level PanelWindows (Topbar, Wallpaper, Notifications)
widgets/                 Individual topbar widgets (Battery, Volume, Network, Clock, Workspaces, ...)
services/                Singleton state/services backed by shell processes (Niri, Clipboard, SystemResources)
components/              Reusable UI pieces (Popup, MyTooltip, TextInfoReveal)
config/                  Singletons for theming — Fonts.qml (colors/typography), Icons.qml (icon/image paths)
utilities/               Setting.qml — persisted user settings (Qt.labs.settings), Utilities.qml (JSON helper)
icons/                   SVG icons used by widgets
images/                  Wallpaper images
scripts/node/            Auxiliary scripts (niri.js — currently an empty placeholder)
```

## Configuration

- **Colors & fonts**: edit `config/Fonts.qml` (font family/sizes and the color palette used across the topbar widgets). Most colors are read from environment variables — `THEME_BLUE`, `THEME_FG`, `THEME_DANGER`, `THEME_WARNING`, `THEME_SUCCESS` — which must be set in the environment Quickshell is launched from.
- **Icon/image paths**: `config/Icons.qml` resolves paths under `icons/` and `images/` relative to the shell directory.
- **Persisted settings**: `utilities/Setting.qml` stores a user-adjustable font family and font sizes via `Qt.labs.settings`.
- **Enabling/disabling widgets**: toggle widgets in the topbar by commenting/uncommenting entries in `windows/Topbar.qml`.

## Running

This directory is expected to live at (or be symlinked to) `~/.config/quickshell`. Launch it with:

```sh
qs
```

(Niri starts it this way via `spawn-sh-at-startup "qs"`.)

or, if run directly from this path:

```sh
quickshell -p shell.qml
```

The launcher is a separate config and is run on its own:

```sh
qs -p ~/.config/quickshell/shells/launcher/shell.qml
```

## IPC

Popups are toggled through Quickshell `IpcHandler`s, so they can be bound to compositor keys:

| Target | Functions | Defined in | Example |
| --- | --- | --- | --- |
| `clipboard` | `toggle`, `show`, `hide`, `isOpen` | `widgets/Clipboard.qml` | `qs ipc call clipboard toggle` (bound to `Mod+C` in niri) |
| `launcher` | `toggle`, `show`, `hide` | `shells/launcher/shell.qml` | `qs -p ~/.config/quickshell/shells/launcher/shell.qml ipc call launcher toggle` |

## Notes

- `widgets/Hyprland.qml` and `widgets/HyprlandActiveClient.qml` are legacy/alternate widgets for a Hyprland session and are not wired into the current Niri-based `Topbar.qml`.
- `NiriService` and `ClipboardService` shell out to `niri` and `cliphist`/`wl-copy` respectively; both must be installed and on `PATH` for their widgets to function.
