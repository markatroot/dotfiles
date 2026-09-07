# niri config

Personal [niri](https://github.com/YaLTeR/niri) window manager configuration, using the Catppuccin Mocha color palette.

## Layout

```
config.kdl              # entry point, includes everything below + startup commands
config/
  input.kdl             # keyboard, touchpad, mouse, trackpoint settings
  output.kdl             # monitor (eDP-1) resolution/scale/position
  layout.kdl             # gaps, column widths, focus ring, border, shadow
  binds.kdl              # keybindings
  gestures.kdl           # touchpad gestures / hot corners
  animations.kdl         # animation settings
  hotkey-overlay.kdl     # "important hotkeys" popup behavior
  window-rule.kdl        # per-app window rules (floating, sizing, corners)
  layer-rule.kdl         # layer-shell rules (wallpaper backdrop, etc.)
  overview.kdl           # workspace overview appearance
scripts/
  term.sh                # picks the working directory for new terminals
  desktop-portal         # restarts xdg-desktop-portal for screen sharing/capture
  video-record.sh        # wf-recorder toggle script
```

## Startup

On launch, `config.kdl` spawns:
- `qs` — status bar (Quickshell)
- `scripts/desktop-portal` — sets up the correct xdg-desktop-portal backend for screen sharing
- `wl-paste` watchers piping into `cliphist` for text and image clipboard history

Wallpaper spawn is currently commented out (`wbg`).

## Key bindings

Mod is Super.

**Apps**
| Bind | Action |
|---|---|
| `Mod+Return` | Terminal (foot) |
| `Mod+Shift+Return` | Terminal (foot, minimal config) |
| `Mod+B` | Terminal (kitty) |
| `Mod+D` | App launcher (wofi) |
| `Mod+C` | Clipboard history (cliphist + wofi) |
| `Mod+P` | Color picker (hyprpicker → clipboard) |
| `Print` | Region screenshot (wayfreeze + grim + slurp + satty) |

New terminals open in the directory reported by `scripts/term.sh` (defaults to `$HOME`, or a saved path in `~/Documents/Temp/whereami`).

**Focus / move windows**
| Bind | Action |
|---|---|
| `Mod+Left/Down/Up/Right` or `Mod+H/J/K/L` | Focus column/window |
| `Mod+Ctrl+Left/Down/Up/Right`, `Mod+Shift+H/J/K/L` | Move column/window |
| `Mod+Home` / `Mod+End` | Focus first/last column |
| `Mod+Shift+Left/Down/Up/Right` | Focus monitor |
| `Mod+Shift+Ctrl+H/J/K/L` | Move column to monitor |

**Workspaces**
| Bind | Action |
|---|---|
| `Mod+U` / `Mod+I` (or `Page_Down`/`Page_Up`) | Focus workspace down/up |
| `Mod+Ctrl+U` / `Mod+Ctrl+I` | Move column to workspace down/up |
| `Mod+Shift+U` / `Mod+Shift+I` | Move workspace down/up |
| `Mod+1`–`9` | Focus workspace N |
| `Mod+Ctrl+1`–`9` | Move column to workspace N |

**Window management**
| Bind | Action |
|---|---|
| `Mod+O` | Toggle overview |
| `Mod+W` | Close window |
| `Mod+BracketLeft/Right` | Consume/expel window left/right |
| `Mod+Comma` / `Mod+Period` | Consume into / expel from column |
| `Mod+R` / `Mod+Shift+R` | Cycle preset column width (fwd/back) |
| `Mod+Ctrl+Shift+R` / `Mod+Ctrl+R` | Cycle/reset preset window height |
| `Mod+F` | Maximize column |
| `Mod+Shift+F` | Fullscreen window |
| `Mod+M` | Maximize window to edges |
| `Mod+Ctrl+F` | Expand column to available width |
| `Mod+Ctrl+C` | Center visible columns |
| `Mod+Minus/Equal` | Adjust column width -/+10% |
| `Mod+Shift+Minus/Equal` | Adjust window height -/+10% |
| `Mod+V` | Toggle floating |
| `Mod+Shift+V` | Switch focus between floating/tiling |

**System**
| Bind | Action |
|---|---|
| `Mod+Shift+Slash` | Show hotkey overlay |
| `Mod+Escape` | Toggle keyboard shortcut inhibitor |
| `Mod+Shift+E` / `Ctrl+Alt+Delete` | Quit (with confirmation) |
| `Mod+Shift+P` | Power off monitors |
| Volume / mic mute / media / brightness keys | Handled via `wpctl`, `playerctl`, `brightnessctl` |

## Window rules

- All windows: 5px rounded corners, clipped to geometry.
- `kitty`: opens maximized.
- `com.gabm.satty` (screenshot annotator): opens floating, 400–1000×200–900.
- `mpv`: opens floating, 400–1300×200–1000.
- `thunar`: opens floating at 50%×50%.

## Layout / theming

- 8px gaps, focus ring in Catppuccin blue (`#89b4fa`), border disabled by default (Mauve `#cba6f7` when enabled).
- Transparent background, shadows configured but disabled by default.
- Hot corners are disabled.

## Dependencies

Referenced by binds/scripts/startup: `foot`, `kitty`, `wofi`, `wayfreeze`, `grim`, `slurp`, `satty`, `hyprpicker` (via `niri msg pick-color`), `cliphist`, `wl-paste`/`wl-copy`, `wpctl`, `playerctl`, `brightnessctl`, `qs` (Quickshell), `xdg-desktop-portal-hyprland`/`xdg-desktop-portal`, `wf-recorder` (for `video-record.sh`).

## Notes

- Output config in `config/output.kdl` targets a laptop panel `eDP-1` at `2560x1600@60`; adjust for your hardware (`niri msg outputs` lists connected displays).
- `$CONFIG_PATH` is expected to be set in the environment and point at the parent of this `niri/` directory (e.g. `~/.mark/config`), since binds reference `$CONFIG_PATH/foot/...`, `$CONFIG_PATH/niri/scripts/...`, etc.
