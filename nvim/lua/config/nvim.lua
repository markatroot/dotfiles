-- Core config bootstrap: loads options/keymaps and exposes M.load_highlights,
-- which re-applies theme + statusline/tabline/winbar highlights whenever the
-- colorscheme changes (see the ColorScheme autocmd in lua/config/theme.lua).
local M = {}

if vim.g.neovide then
  require 'config.neovide'
end

require 'config.mapping'
require 'config.options'
require 'custom.menu.menu'
require 'my_plugin.notes'

-- Legacy command name kept from the old packer.nvim setup.
-- NOTE: calls M.load_hightlights (typo'd), not the M.load_highlights defined
-- below, left as-is to avoid changing existing behavior.
vim.api.nvim_create_user_command('PackerCompileDone', function()
  M.load_hightlights()
end, {})

vim.api.nvim_create_user_command('PackUpdate', function()
  vim.pack.update()
end, {})

function M.load_highlights()
  require 'config.highlights'.load()
  require 'config.ui2'.load()
  require 'custom.eyecandy.statusline'
  require 'custom.eyecandy.tabline'
  require 'custom.eyecandy.winbar'
end

return M
