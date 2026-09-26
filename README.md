# dotfiles

Personal configuration for a Wayland desktop built on [niri](https://github.com/YaLTeR/niri) (scrolling-tile compositor) and [Quickshell](https://quickshell.outfoxxed.me/) (status bar/shell), themed with a mix of One Dark, Dracula, and Catppuccin palettes, with `Comic Code` as the primary font.

This directory is expected to live at (or be symlinked from) `~/.mark/config`, exported as `$CONFIG_PATH`. Several configs (niri binds, scripts) reference `$CONFIG_PATH` directly, so that env var must be set before niri starts.

## Screenshots

| niri | Quickshell | nvim |
|---|---|---|
| ![niri](screenshots/niri.png) | ![Quickshell](screenshots/quickshell.png) | ![nvim](screenshots/nvim.png) |

## Layout

| Path | What it is |
|---|---|
| [`niri/`](niri/README.md) | Window manager config — binds, layout, animations, window/layer rules, startup scripts |
| [`quickshell/`](quickshell/README.md) | Desktop shell (QML) — topbar, wallpaper, notifications |
| [`nvim/`](nvim/README.md) | Neovim config — `vim.pack`-based plugin management, LSP, custom UI |
| `kitty/` | Terminal emulator config — `kitty.conf` includes `current-theme.conf` (OneDark-Pro); `dark-theme.auto.conf` (Catppuccin Mocha) is picked up automatically by kitty when the OS prefers dark; `themes/catppuccin/mocha.conf` is a spare copy not referenced by `kitty.conf` |
| `foot/` | Terminal emulator config (`foot.ini`, Comic Code + One Dark colors), plus a `minimal_foot.ini` variant (Macon font, default colors) bound separately in niri |
| `wofi/` | App launcher — `wofi` (config: style path, `term=kitty`, `Alt-j`/`Alt-k` navigation) and `style.css` |
| `mpv/` | Video player config — `mpv.conf` (only `fs=yes` active), a fully commented `input.conf`, plus stock reference files (`mplayer-input.conf`, `restore-*-bindings.conf`, `encoding.rst`, `tech-overview.txt`) |
| `satty/` | Screenshot annotation tool config (`config.toml`: brush tool on start, `wl-copy`, saves to `~/Pictures/Screenshots/`) — used by niri's screenshot bind |
| `yazi/` | Terminal file manager config (`yazi.toml`, `keymap.toml`, `theme.toml`) and bundled flavors (Catppuccin Frappé/Latte/Macchiato/Mocha, Dracula) — `theme.toml` selects `dracula` for both dark and light |
| `chromium-flags.conf` | Flags for Chromium/Electron apps under Wayland (Ozone, PipeWire screen capture, plus `--process-per-site` and background-throttling/networking tweaks) |
| `screenshots/` | Images used in this README (`niri.png`, `quickshell.png`, `nvim.png`) |

See each subdirectory's own README for details — `niri`, `quickshell`, and `nvim` are the largest pieces and are documented in depth.

## Theming

No single shared theme file — colors are duplicated per app:

- **One Dark** — kitty (`current-theme.conf`, OneDark-Pro), foot (`foot.ini` `[colors-dark]`), niri inactive focus-ring color (`#3e4451`; the border is `off`)
- **Catppuccin Mocha** — kitty's `dark-theme.auto.conf` (applied automatically in OS dark mode)
- **Dracula**-ish purples (`#bd93f9`, `#282a36`, `#44475a`) — wofi, niri active focus ring (`#bd93f9`), yazi (`dracula` flavor)
- **Comic Code** — primary font across foot (`foot.ini`), kitty (`Comic Code Ligatures`), and satty; exceptions: `minimal_foot.ini` uses Macon, wofi uses Cascursive

## Key apps wired together

- Screenshots: `Print` in niri → `wayfreeze` + `grim` + `slurp` → `satty` (annotate) → clipboard/file
- Clipboard history: `wl-paste` watchers (started by niri) → `cliphist` → Quickshell clipboard panel (`Mod+C` runs `qs ipc call clipboard toggle`; the old wofi picker is commented out)
- Launcher: `wofi --show drun` (`Mod+D`)
- Terminals: `foot` (`Mod+Return`, `foot.ini`; `Mod+Shift+Return`, `minimal_foot.ini`) and `kitty` (`Mod+B`), all launched by niri binds
- Screen sharing: niri's `scripts/desktop-portal` sets up `xdg-desktop-portal`; `chromium-flags.conf` enables PipeWire capture in Chromium-based apps

## Notes

- `nvim/swap/` may exist locally with leftover `.swp` files from past sessions, but it is gitignored (`nvim/.gitignore`) and not part of the repo — swapfile writing itself is disabled in the nvim config.
- `kitty/kitty.conf.bak` is a backup, not loaded by kitty.
- `mpv/mpv.conf` is largely the stock example config with most options commented out; only `fs=yes` is active. `mpv/input.conf` is likewise entirely commented out.
