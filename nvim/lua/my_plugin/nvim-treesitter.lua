-- Unused: not required anywhere (parser install/highlighting is currently
-- handled by tree-sitter-manager.nvim instead, see
-- lua/my_plugin/tree-sitter-manager.lua). Kept for reference.
require('nvim-treesitter').setup({
  highlight = {
    enable = true,
    disable = { 'html' },
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = 'ss',    -- start selection
      node_incremental = 'sn',  -- expand to next node
      scope_incremental = 'si', -- expand to scope (like function/block)
      node_decremental = 'sd',  -- shrink selection
    },
  },
  textobjects = { enable = true },
  additional_vim_regex_highlighting = false,
})
