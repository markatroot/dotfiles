-- Keymaps for the work-log helper in lua/custom/note/note.lua.
local U = require 'config.utils'

local file_path = require 'custom.note.note'.file_path

local opt = { silent = true }
U.map('n', '<leader>ne', ':bo 15sp ' .. file_path .. '<cr>', opt)
U.map('n', '<leader>np', ":lua require'custom.note.note'.preview()<cr>", opt)
U.map('n', '<leader>ng', ":lua require'custom.note.note'.generate()<cr>", opt)
U.map('n', '<leader>na', ":lua require'custom.note.note'.add()<cr>", opt)
U.map('n', '<leader>nab', ":lua require'custom.note.note'.add_by_day()<cr>", opt)
