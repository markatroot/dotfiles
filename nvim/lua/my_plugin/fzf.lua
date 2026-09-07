-- fzf.vim keymaps. Not currently in the plugin list (init.lua / lua/custom/pack),
-- so `fzf#run` isn't defined and these mappings would error if triggered.
local U = require 'config.utils'

-- Open files in a horizontal split at the bottom
U.map('n', '<Leader>fo', ":call fzf#run({ 'down': '30%', 'sink': 'e' })<cr>", { silent = true })
-- Open files in horizontal split
U.map('n', '<Leader>fh', ":call fzf#run({ 'down': '30%', 'sink': 'split' })<cr>", { silent = true })
-- Open files in vertical horizontal split
U.map('n', '<Leader>fv', ":call fzf#run({ 'down': '30%', 'sink':  'vsplit' })<cr>", { silent = true })
-- Open files in vertical horizontal split
U.map('n', '<Leader>ft', ":call fzf#run({ 'down': '30%', 'sink':  'tabedit' })<cr>", { silent = true })
