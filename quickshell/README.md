# Quickshell Config

A [Quickshell](https://quickshell.outfoxxed.me/) desktop shell for a Wayland session running the [Niri](https://github.com/YaLTeR/niri) scrolling compositor. Provides a topbar, a live wallpaper window, desktop notification popups, and a keyboard-driven clipboard history popup, all written in QML. A separate standalone app launcher shell lives in `shells/launcher/`.

![Quickshell](../screenshots/quickshell.png)

## Features

- **Topbar** (`windows/Topbar.qml`) — a transparent `wlr-layer-shell` panel (namespace `quickshell:topbar`) anchored to the top of the screen, holding two bordered "pills" drawn with the `Theme.surface`/`surfaceBorder`/`radius` tokens:
  - **OS pill** — an Arch logo (`widgets/Os.qml`)
  - **Main pill** (full width) — on the left, Niri workspaces as numbers (the focused one is a magenta pill, the others are dimmed and highlight on hover; click to focus) and the active window title. On the right, CPU/memory usage, a divider, then clipboard history, volume (tap the icon to toggle mute), network, battery, and the system tray
  - Volume, network, and battery show their details while hovered, and briefly when their value changes (`components/HoverReveal.qml`; changes in the first 2s after startup are ignored)
  - System tray (`widgets/SystemTray.qml`) uses its own themed popup menu with submenu support (`widgets/TrayMenuRow.qml`) instead of the native menu
  - Clock and screen recorder widgets exist but are commented out; uncomment them in `Topbar.qml` to turn them on
- **Clipboard history** (`widgets/Clipboard.qml`) — clicking the topbar icon (or the `clipboard` IPC target, see below) opens a searchable `cliphist` popup as a top-right overlay layer-shell window; arrow keys/Tab to navigate, Enter to copy, Esc to close, "Clear" to wipe history
- **Wallpaper** (`windows/Wallpaper.qml`) — a background layer-shell window (namespace `quickshell:my-wallpaper`) rendering a large date/time clock (`widgets/Clock.qml`) over a `Theme.bg` fill, plus layered background images (`images/forest-one-dark.png`, `images/chowy_front.png`; `images/forest.png` is unused)
- **Notifications** (`windows/Notifications.qml`) — a minimal notification popup daemon (via `Quickshell.Services.Notifications`), one panel per screen, anchored top-right; supports images/app icons, body markup, and action buttons, auto-dismisses after the notification's timeout (6s default), and dismisses on click or ✕. Cards use the same surface/border/radius as the topbar pills; the color tunables at the top of the file map to `Theme` colors
- **App launcher** (`shells/launcher/shell.qml`) — a separate, self-contained Quickshell config (not loaded by `shell.qml`): a centered fuzzy-search launcher over desktop entries, toggled via the `launcher` IPC target

## Requirements

- [Quickshell](https://quickshell.outfoxxed.me/) (Qt6/QML runtime)
- [Niri](https://github.com/YaLTeR/niri) — workspace/window state is read via `niri msg --json event-stream`
- A Nerd Font (`SFMono Nerd Font` by default, see `config/Fonts.qml`) for icon glyphs
- `THEME_*` color variables (from `~/env/dotfiles/rc/themerc`) in the environment Quickshell starts from. They're optional, since `config/Theme.qml` falls back to One Dark
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
widgets/                 Individual topbar widgets (Os, Workspaces, Battery, Volume, Network, SystemTray, ...)
services/                Singleton state/services backed by shell processes (Niri, Clipboard, SystemResources)
components/              Reusable UI pieces (Popup, MyTooltip, TextInfoReveal, HoverReveal)
config/                  Singletons — Theme.qml (colors + surface tokens), Fonts.qml (typography), Icons.qml (icon/image paths)
utilities/               Setting.qml — persisted user settings (Qt.labs.settings), Utilities.qml (JSON helper)
icons/                   SVG icons used by widgets
images/                  Wallpaper images
scripts/node/            Auxiliary scripts (niri.js — currently an empty placeholder)
```

## Configuration

- **Colors**: `config/Theme.qml` reads every color from `THEME_*` environment variables (`THEME_BG`, `THEME_FG`, the 16 ANSI colors, `THEME_PRIMARY`, `THEME_SELECTION`, `THEME_DANGER`, ...) via `Quickshell.env()`, falling back to One Dark. It also defines the shared `surface`, `surfaceBorder` (`bg` lightened 1.6×), and `radius` (5) tokens used by the topbar pills, notification cards, tray menu, and clipboard popup. Change the palette in themerc, not here.
- **Fonts**: `config/Fonts.qml` sets the font family (`mono`) and the size scale (`xs`–`xxl`).
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
