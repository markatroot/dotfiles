# nvim config

Personal Neovim configuration. Plugins are managed with Neovim's built-in
`vim.pack` (no packer/lazy.nvim/vim-plug), wrapped by a small custom layer
that adds lazy-loading by filetype.

## Requirements

- Neovim with `vim.pack` (0.12+ / nightly)
- `git` (for plugin installs via `vim.pack`)
- [`biome`](https://biomejs.dev/), `prettier`, and [`stylua`](https://github.com/JohnnyMorganz/StyLua) on `$PATH` for formatting
- Language servers configured under `lua/lsp/servers/` (jsonls, csharp_ls, vtsls, tsgo, qmlls, angularls, somesass_ls, omnisharp — see below for which are enabled)
- [`netcoredbg`](https://github.com/Samsung/netcoredbg) for C# debugging (path is hardcoded in `lua/my_plugin/nvim-dap/nvim-dap.lua`, so this is machine-specific)

## Entry point

- `init.lua` — declares the plugin spec table and calls into `lua/custom/pack/pack.lua` to install/load them.
- `sysinit.vim` — alternate entry point (`nvim -u sysinit.vim`) that just `dofile`s `init.lua` directly, using the `NVIM_RTP` env var to locate it.

## Directory layout

```
init.lua                   Plugin spec list + entry point
lua/config/                Core setup: options, keymaps, theme, highlights, statusline pieces
lua/custom/pack/           Thin wrapper around vim.pack (eager + filetype/command-lazy loading)
lua/custom/menu/           Floating command-runner menu (see g:menu_commands)
lua/custom/note/           Work-log / scratch note helper
lua/custom/eyecandy/       Custom statusline, tabline, winbar
lua/custom/columnline/     Custom colorcolumn/indent-line helper
lua/my_plugin/             Per-plugin setup + keymaps (one file per plugin)
lua/lsp/                   LSP glue: diagnostics, code actions, omnifunc, per-server configs
lua/lsp/servers/           One config module per language server
ftplugin/                  Filetype-specific settings (C#, cshtml)
plugin/lsp.lua             LSP attach/detach wiring, auto-sourced on startup
autoload/menu.vim          Vimscript side of the command-runner menu
swap/                      Swapfile directory (swapfile itself is disabled; leftover .swp files)
```

## Plugin manager

`lua/custom/pack/pack.lua` wraps `vim.pack.add`. Each spec in `init.lua`'s
`pack` table takes:

- `src` — `"user/repo"` GitHub shorthand
- `ft` — if set, the plugin installs/loads lazily on `FileType` for those filetypes
- `pattern` — if set, installs lazily on `CmdUndefined` for that command (currently unused by any spec)
- `init` — runs before install
- `config` — runs after install/load

Everything else installs eagerly at startup.

Run `:PackUpdate` to update all plugins (wraps `vim.pack.update()`).

## Plugins

**Theme / UI**
- `onedarkpro.nvim` — colorscheme (`lua/config/theme.lua`)
- Custom statusline/tabline/winbar (`lua/custom/eyecandy/`)

**Navigation / fuzzy finding**
- `telescope.nvim` (+ `telescope-fzf-native.nvim`, `plenary.nvim`) — file/grep pickers and LSP pickers, see `lua/my_plugin/telescope.lua`
- `neo-tree.nvim` — file tree, toggled with `<C-i>`

**Editing**
- `mini.surround` — surround text objects
- `autoclose-nvim` — auto-close brackets/quotes
- `nvim-autopairs`
- `luasnip` — snippets (see `snippets/typescript.snippets`)
- `emmet-vim` — HTML/CSS abbreviations
- `tree-sitter-manager.nvim` — treesitter parser management

**LSP / formatting**
- Native `vim.lsp` + `formatter.nvim` (biome for JS/TS, prettier for HTML, stylua for Lua)
- `nvim-dap` — debugging (C#/JS), F5/F10/F11/F12 + `<leader>` mappings

**Git**
- `blamer.nvim` — inline git blame

**Filetype extras**
- `html5.vim`, `vim-javascript`, `vim-lua`

## LSP

Configured centrally in `plugin/lsp.lua`, which is auto-sourced by Neovim on
startup (no `require` needed). Servers live under `lua/lsp/servers/` and are
enabled per-filetype via `vim.lsp.enable`. Currently attached: `jsonls`,
`csharp_ls`, `tsgo`, `qmlls`. `vtsls`, `somesass_ls`, and `angularls` have
configs but are not attached (`attach = false` in the `SERVERS` table).

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
| `<leader>p`                     | Format buffer                    |
| `<C-i>`                          | Toggle Neo-tree (floating)       |
| `<C-p>`                          | Find files                       |
| `<C-o>`                          | Live grep                        |
| `<C-l>`                          | Live grep in current file's dir  |
| `<C-u>`                          | Live grep by file extension      |
| `<C-n>` / `<C-no>`               | Find files / grep in this nvim config |
| `<leader>ne` / `<leader>np`      | Open / preview work-log note     |
| `<leader>na` / `<leader>nab`     | Add note / add note by day       |
| `<F5>` `<F10>` `<F11>` `<F12>`   | DAP continue / step over / into / out |
| `<leader>b` / `<leader>B`        | Toggle breakpoint / conditional breakpoint |

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
  in the plugin list, so these currently error if triggered.
- `lua/config/nvim.lua`: `PackerCompileDone` calls `M.load_hightlights`
  (typo), not the `M.load_highlights` defined in the same file.
