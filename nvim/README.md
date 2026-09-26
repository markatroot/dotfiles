# nvim config

Personal Neovim configuration. Plugins are managed with Neovim's built-in
`vim.pack` (no packer/lazy.nvim/vim-plug), wrapped by a small custom layer
that adds lazy-loading by filetype.

![nvim](../screenshots/nvim.png)

## Requirements

- Neovim with `vim.pack` (0.12+ / nightly)
- `git` (for plugin installs via `vim.pack`)
- [`biome`](https://biomejs.dev/), `prettier`, and [`stylua`](https://github.com/JohnnyMorganz/StyLua) on `$PATH` for formatting
- Language servers configured under `lua/lsp/servers/` (jsonls, csharp_ls, vtsls, qmlls, plus configs for angularls, somesass_ls, tsserver, tsgo, omnisharp, biome, cssls, denols, dartls, sumneko_lua — see below for which are enabled)
- [`netcoredbg`](https://github.com/Samsung/netcoredbg) for C# debugging (path is hardcoded in `lua/my_plugin/nvim-dap/nvim-dap.lua` and `nvim-dap-adapters.lua`, so this is machine-specific; the node2 adapter path under `~/Documents/Compiled/vscode-node-debug2` is too)

## Entry point

- `init.lua` — declares the plugin spec table and calls into `lua/custom/pack/pack.lua` to install/load them.
  Core config (`lua/config/nvim.lua`: keymaps, options, menu, notes, Neovide) isn't required from `init.lua`
  directly; it's pulled in by the `onedarkpro` spec's `config` → `config.theme` → `config.nvim`.
- `sysinit.vim` — alternate entry point (`nvim -u sysinit.vim`) that just `dofile`s `init.lua` directly, using the `NVIM_RTP` env var to locate it.

## Directory layout

```
init.lua                   Plugin spec list + entry point
lua/config/                Core setup: options, keymaps, theme, highlights, utils,
                           ui2 (experimental msg/cmdline UI), neovide (GUI-only settings)
lua/custom/pack/           Thin wrapper around vim.pack (eager + filetype/command-lazy loading)
lua/custom/menu/           Command list for the runner menu (g:menu_commands) + nui-based input.lua prompt
lua/custom/note/           Work-log / weekly report helper (gitignored)
lua/custom/eyecandy/       Custom statusline, tabline, winbar (statusline_global.lua is unused)
lua/custom/columnline/     Colorcolumn helper (unused, not required anywhere)
lua/my_plugin/             Per-plugin setup + keymaps (one file per plugin; some unused, see below)
lua/lsp/                   LSP glue: diagnostics, code actions, omnifunc, per-server configs
lua/lsp/servers/           One config module per language server
ftplugin/                  Filetype-specific settings (C#, cshtml)
plugin/lsp.lua             LSP attach/detach wiring, auto-sourced on startup
autoload/menu.vim          Vimscript side of the command-runner menu
snippets/                  Snippet files (typescript; LuaSnip itself isn't installed)
swap/                      Swapfile directory (swapfile itself is disabled; leftover .swp files, gitignored)
```

## Plugin manager

`lua/custom/pack/pack.lua` wraps `vim.pack.add`. Each spec in `init.lua`'s
`pack` table takes:

- `name` — plugin name passed to `vim.pack`
- `src` — `"user/repo"` GitHub shorthand
- `ft` — if set, the plugin installs/loads lazily on `FileType` for those filetypes
- `pattern` — if set, installs lazily on `CmdUndefined` for that command (currently unused by any spec)
- `init` — runs before install
- `config` — runs after install/load

Everything else installs eagerly at startup. Any other key (e.g. the
`dependencies` list on the telescope spec) is ignored by the wrapper.

Run `:PackUpdate` to update all plugins (wraps `vim.pack.update()`).

## Plugins

**Theme / UI**
- `onedarkpro.nvim` — colorscheme (`lua/config/theme.lua`)
- `nui.nvim` — popup/input primitives (`lua/custom/menu/input.lua`, used for LSP code-action prompts and the Neo-tree command runner)
- Custom statusline/tabline/winbar (`lua/custom/eyecandy/`)
- Neovim's built-in `vim._core.ui2` message/cmdline UI (`lua/config/ui2.lua`)
- Neovide settings/keymaps when running under Neovide (`lua/config/neovide.lua`)

**Navigation / fuzzy finding**
- `telescope.nvim` (+ `telescope-fzf-native.nvim`, `plenary.nvim`) — file/grep pickers and LSP pickers, see `lua/my_plugin/telescope.lua`
- `neo-tree.nvim` — file tree, toggled with `<C-i>`; `<leader>s` on a node prompts for a shell command to run in that directory

**Editing**
- `mini.surround` — surround text objects (`sa`/`sd`/`sr`/`sf`/`sF`/`sh`)
- `emmet-vim` — HTML/CSS abbreviations (insert `<C-l>` expand, `<C-j>`/`<C-k>` next/prev)
- `tree-sitter-manager.nvim` — treesitter parser management + highlighting (loaded eagerly; its `ft` list is commented out)

**LSP / formatting**
- Native `vim.lsp` + `formatter.nvim` (biome for JS/TS, prettier for HTML, stylua for Lua)
- `nvim-dap` — debugging (C#/JS), F5/F10/F11/F12 + `<leader>` mappings

**Git**
- `blamer.nvim` — inline git blame

**Filetype extras**
- `html5.vim`, `vim-javascript`, `vim-lua`
- `markview.nvim` — Markdown rendering (lazy on `markdown`; `lua/my_plugin/markview.lua` is empty, so defaults apply)

**Unused configs**

These files under `lua/my_plugin/` aren't loaded by anything (the plugin
isn't in the `pack` table and/or nothing `require`s the module), kept for
reference: `autoclose-nvim.lua`, `nvim-autopairs.lua`, `luasnip.lua`,
`nvim-treesitter.lua`, `fzf.lua`, `menu.lua`, `blamer.lua`, `titlestring.lua`.

## LSP

Configured centrally in `plugin/lsp.lua`, which is auto-sourced by Neovim on
startup (no `require` needed). Servers live under `lua/lsp/servers/` and are
enabled per-filetype via `vim.lsp.enable`. Currently attached: `jsonls`,
`csharp_ls`, `vtsls`, `qmlls`. `somesass_ls`, `tsserver`, and `angularls` are
listed but not attached (`attach = false` in the `SERVERS` table), and
`omnisharp` is commented out. `tsgo`, `biome`, `cssls`, `denols`, `dartls`,
and `sumneko_lua` have config modules but aren't in `SERVERS` at all.

On attach, inlay hints and semantic tokens are disabled, built-in
`vim.lsp.completion` is enabled (no autotrigger), and line diagnostics open
in a float on `CursorHold`.

Buffer-local mappings on `LspAttach` (see `M.lsp_mappings` in `plugin/lsp.lua`):

| Key          | Action                  |
|--------------|-------------------------|
| `<C-j>`      | next diagnostic         |
| `<C-k>`      | prev diagnostic         |
| `gd`         | go to definition        |
| `gi`         | go to implementation    |
| `gr`         | references              |
| `gs`         | document symbols        |
| `K`          | hover                   |
| `<C-k>` (insert) | signature help      |
| `<leader>s`  | code action             |
| `<leader>rn` | rename                  |
| `<leader>o`  | organize imports        |
| `<leader>ai` | add missing imports     |
| `<leader>f`  | format                  |
| `<leader>rf` | rename file (TS only)   |

## General keymaps

Leader is `,`.

| Key                            | Action                          |
|---------------------------------|----------------------------------|
| `jj` (insert)                   | Escape to normal mode            |
| `<Right>` / `<Left>`            | Resize window vertically ±5      |
| `<Up>` / `<Down>`                | Resize window horizontally ±5    |
| `<leader>p`                     | Format buffer (`:Format`; mapped on first `LspAttach`) |
| `<C-i>`                          | Toggle Neo-tree (floating)       |
| `<C-p>`                          | Find files                       |
| `<C-o>`                          | Live grep                        |
| `<C-l>`                          | Live grep in current file's dir  |
| `<C-u>`                          | Live grep by file extension      |
| `<C-n>` / `<C-no>`               | Find files / grep in this nvim config |
| `<leader>ne` / `<leader>np`      | Open / preview work-log note     |
| `<leader>na` / `<leader>nab`     | Add note / add note by day       |
| `<leader>ng`                     | Generate weekly work-log report  |
| `<C-w>h/j/k/l` (terminal)        | Leave terminal mode + move window |
| `<leader>gb`                     | Git blame (broken, see below)    |
| `<F5>` `<F10>` `<F11>` `<F12>`   | DAP continue / step over / into / out |
| `<leader>b` / `<leader>B`        | Toggle breakpoint / conditional breakpoint |
| `<leader>lp`                     | DAP log point                    |
| `<leader>do` / `<leader>ds`      | DAP REPL / REPL (50x50)          |
| `<leader>dr` / `<leader>dl`      | DAP restart / run last           |
| `<leader>dh`                     | DAP hover widget                 |

Neovide only: `<M-K>`/`<M-J>` font size ±1, `<M-s>` save, `<M-c>` copy
(visual), `<M-v>` paste (normal/visual/insert/command).

## Known issues

A few rough edges currently in the config, left as-is:

- `lua/config/mapping.lua`: `<leader>gb` calls `git.blame` (module doesn't
  exist) instead of `my_plugin.blamer`; will error if triggered.
- `lua/config/mapping.lua`: the terminal-mode window mappings pass an
  undefined `option` global instead of `{ silent = true }`.
- `lua/my_plugin/nvim-dap/nvim-dap.lua`: all DAP keymaps pass an undefined
  `options` global instead of the `opts` table defined just above them.
- `lua/config/theme.lua`: the `ColorScheme` autocmd group is set to an
  undefined `lsp` global (same effect as omitting `group`).
- `lua/my_plugin/telescope.lua`: `load_extension('fzf')` is never called, so
  the fzf-native extension config has no effect; `borderchars` also points at
  the wrong table and is always nil.
- `lua/my_plugin/fzf.lua`: mappings reference `fzf#run`, but `fzf.vim` isn't
  in the plugin list; the module isn't required anywhere today, but would
  error if it were loaded and triggered.
- `lua/config/nvim.lua`: `PackerCompileDone` calls `M.load_hightlights`
  (typo), not the `M.load_highlights` defined in the same file.
- `plugin/lsp.lua`: the `LspDetach` handler checks
  `vim.fn.exists('nmap <c-j>')`-style strings, which aren't a valid
  `exists()` form and always return 0, so LSP keymaps are never removed on
  detach.
- `lua/custom/eyecandy/winbar.lua`: `WinEnter`/`BufEnter` call
  `my_winbar(true)` (blank) and `WinLeave`/`BufLeave` call `my_winbar(false)`
  (filename), so the filename shows in inactive windows instead of the
  active one.
