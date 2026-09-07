-- Custom keymaps. General editor mappings; plugin-specific mappings live
-- alongside their plugin config under lua/my_plugin/.
local U = require 'config.utils'

vim.g.mapleader = ','

-- Window resizing
U.map('n', '<Right>', ':vertical resize +5<cr>', { silent = true })
U.map('n', '<Left>', ':vertical resize -5<cr>', { silent = true })
U.map('n', '<Up>', ':5winc -<cr>', { silent = true })
U.map('n', '<Down>', ':5winc +<cr>', { silent = true })

-- NOTE: no lua/git/blame.lua module exists; this likely meant to point at
-- my_plugin.blamer.blame() and currently errors when triggered.
U.map('n', '<leader>gb', ":lua require'git.blame'.blame()<cr>", { silent = true })
U.map('n', '<leader>p', ':Format<cr>', { silent = true })

-- Escape insert mode by typing 'jj'
U.map('i', 'jj', '<Esc>')

-- Move between windows from terminal mode.
-- NOTE: `option` below is an undefined global (always nil), so these get no
-- opts at all rather than the { silent = true } the others use.
U.map('t', '<C-w>h', '<C-\\><C-N><C-w>h', option)
U.map('t', '<C-w>j', '<C-\\><C-n><C-j>', option)
U.map('t', '<C-w>k', '<C-\\><C-n><C-k>', option)
U.map('t', '<C-w>l', '<C-\\><C-n><C-l>', option)

-- Plugin mappings
vim.keymap.set('n', '<C-i>', function()
  vim.cmd("Neotree float toggle reveal")
end)
