-- formatter.nvim setup: per-filetype formatters, bound to <leader>p in
-- lua/config/mapping.lua.
local function biome_formatter()
  return {
    exe = 'biome',
    args = {
      'format',
      '--stdin-file-path',
      vim.api.nvim_buf_get_name(0),
    },
    stdin = true,
    try_node_modules = true,
  }
end

local function html_formatter()
  local result = require('formatter.filetypes.html').prettier()
  result.try_node_modules = true
  return result
end

require('formatter').setup({
  logging = true,
  log_level = vim.log.levels.DEBUG,
  filetype = {
    lua = { require('formatter.filetypes.lua').stylua },
    htmlangular = { html_formatter },
    html = { html_formatter },
    typescript = { biome_formatter },
    javascript = { biome_formatter },
    typescriptreact = { biome_formatter },
    javascriptreact = { biome_formatter },
  },
})
