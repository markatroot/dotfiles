# umbriel config

Personal [Umbriel](https://docs.noctalia.dev/umbriel/) compositor config, ported from [`../niri`](../niri/README.md). Colors are rendered from the shared `themerc` palette, as with niri.

Umbriel finds `config.toml` through `XDG_CONFIG_DIRS`, which includes `$CONFIG_PATH`. Check edits with `umbriel config validate`.

## Layout

```
config.toml               # entry point: includes, autostart, environment
config/
  input.toml              # keyboard repeat, numlock, touchpad
  output.toml             # eDP-1 mode/scale/position
  layout.toml             # scrolling layout, gaps, column width presets
  appearance.toml.in      # template for appearance.toml — edit this one (${THEME_*} colors)
  appearance.toml         # generated: border colors, corner radius, shadow
  animation.toml          # spring curves
  overview.toml           # hot corners (off)
  window-rules.toml       # floating rules for satty, mpv, thunar, flameshot
  layer-rules.toml        # none needed yet (overview mirrors the background layer)
  keybinds.toml           # keybinds, same keys as niri
scripts/
  theme.sh                # renders *.toml.in and foot/colors.ini.in from themerc
  term.sh                 # working directory for new terminals (copied from niri)
  pipewire-start.sh       # starts PipeWire for OpenRC; no-op if already running this login (--restart to force)
  desktop-portal          # restarts xdg-desktop-portal with the Umbriel backend
```

## Differences from niri

- No color picker: `Mod+P` (`niri msg pick-color`) is dropped.
- `Ctrl+Print` uses `grim`; `Alt+Print` (window screenshot) is not ported yet.
- Not ported (no direct equivalent): `reset-window-height` (`Mod+Ctrl+R`), `expand-column-to-available-width` (`Mod+Ctrl+F`).
- `Mod+Period` (expel) maps to `window-consume-or-expel-right`; `Mod+Ctrl+C` centers the focused column only.
- Window rules can't set min/max sizes or `clip-to-geometry`, so satty and mpv get a default floating size instead.
- `Mod+Shift+Slash` opens Umbriel's cheatsheet instead of niri's hotkey overlay.

## Still needed before switching

- Packages: `umbriel-git`, `xdg-desktop-portal-umbriel`.
- Launch with `start-umbriel` (`XDG_CURRENT_DESKTOP=umbriel` is set in `~/env/dotfiles/rc/variablesrc`).
