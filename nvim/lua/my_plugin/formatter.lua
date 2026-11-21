-- formatter.nvim setup: per-filetype formatters, bound to <leader>p in
-- plugin/lsp.lua. Prettier handles html/htmlangular, Biome handles the rest.
-- `try_node_modules` prefers a project-local binary over the global one.
local function buf_path()
  return vim.api.nvim_buf_get_name(0)
end

local function biome()
  return {
    exe = 'biome',
    args = { 'format', '--stdin-file-path', buf_path() },
    stdin = true,
    try_node_modules = true,
  }
end

local function prettier(parser)
  return function()
    return {
      exe = 'prettier',
      args = { '--stdin-filepath', buf_path(), '--parser', parser },
      stdin = true,
      try_node_modules = true,
    }
  end
end

local filetype = {
  lua = { require('formatter.filetypes.lua').stylua },
  html = { prettier('html') },
  htmlangular = { prettier('angular') },
}

for _, ft in ipairs({
  'javascript',
  'javascriptreact',
  'typescript',
  'typescriptreact',
  'json',
  'jsonc',
  'css',
  'scss',
  'graphql',
}) do
  filetype[ft] = { biome }
end

require('formatter').setup({
  logging = true,
  log_level = vim.log.levels.WARN,
  filetype = filetype,
})
