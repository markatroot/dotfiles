-- tree-sitter-manager.nvim setup (installs/manages treesitter parsers).
require('tree-sitter-manager').setup({
  highlight = true,
  ensure_installed = {
    'lua',
    'html',
    'typescript',
    'css',
    'scss',
    'angular',
    'json',
    'c_sharp',
  },
})
