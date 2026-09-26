-- Neovide (GUI frontend) settings. Only loaded when running inside Neovide,
-- see the `vim.g.neovide` guard in lua/config/nvim.lua.
local U = require 'config.utils'

local font_family = "Comic Code Ligatures"

vim.g.neovide_font_size = 10

-- text below applies for VimScript
vim.o.guifont = font_family .. ":h" .. vim.g.neovide_font_size

vim.g.neovide_refresh_rate = 30

vim.g.neovide_fullscreen = false

vim.g.neovide_theme = 'dark'

vim.g.neovide_profiler = false
vim.g.neovide_transparency = 0.9
vim.g.neovide_position_animation_length = 0
vim.g.neovide_cursor_animation_length = 0
vim.g.neovide_cursor_animate_in_insert_mode = false

vim.opt.fillchars = {
  eob = 'a',
  horizdown = '-',
  horizup = '-',
  horiz = '-',
}

-- Font size adjustment (Alt-K / Alt-J)
U.keymap('n', '<M-K>', function()
  vim.g.neovide_font_size = vim.g.neovide_font_size + 1
  vim.o.guifont = font_family .. ":h" .. vim.g.neovide_font_size
end)

U.keymap('n', '<M-J>', function()
  vim.g.neovide_font_size = vim.g.neovide_font_size - 1
  vim.o.guifont = font_family .. ":h" .. vim.g.neovide_font_size
end)

-- Allow clipboard copy paste in neovim
vim.g.neovide_input_use_logo = 1
vim.keymap.set('n', '<M-s>', ':w<CR>') -- Save
vim.keymap.set('v', '<M-c>', '"+y') -- Copy
vim.keymap.set('n', '<M-v>', '"+P') -- Paste normal mode
vim.keymap.set('v', '<M-v>', '"+P') -- Paste visual mode
vim.keymap.set('c', '<M-v>', '<C-R>+') -- Paste command mode
vim.keymap.set('i', '<M-v>', '<ESC>l"+Pli') -- Paste insert mode
