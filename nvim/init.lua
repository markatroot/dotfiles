-- Entry point loaded by sysinit.vim. Declares plugins for Neovim's built-in
-- `vim.pack` manager (see lua/custom/pack/pack.lua) and installs them.
local P = require('custom.pack.pack')

local pack = {
  {
    name = 'tree-sitter-manager.nvim',
    src = 'romus204/tree-sitter-manager.nvim',
    ft = {
      'javascript',
      'typescript',
      'lua',
      'html',
      'css',
      'scss',
      'bash',
      'sh',
      'qml',
    },
    config = function()
      require 'my_plugin.tree-sitter-manager'
    end,
  },
  {
    name = 'onedarkpro',
    src = 'olimorris/onedarkpro.nvim',
    config = function()
      require 'config.theme'
    end,
  },
  {
    name = 'nui',
    src = 'MunifTanjim/nui.nvim',
  },
  {
    name = 'mini-surround',
    src = 'nvim-mini/mini.surround',
    config = function()
      require 'my_plugin.mini-surround'
    end,
  },
  {
    name = 'plenary',
    src = 'nvim-lua/plenary.nvim',
  },
  {
    name = 'telescope-fzf-native',
    src = 'nvim-telescope/telescope-fzf-native.nvim',
  },
  {
    name = 'neo-tree',
    src = 'nvim-neo-tree/neo-tree.nvim',
    config = function()
      require 'my_plugin.neo-tree'
    end,
  },
  {
    name = 'formatter',
    src = 'mhartington/formatter.nvim',
    config = function()
      require 'my_plugin.formatter'
    end,
  },
  {
    name = 'html5',
    src = 'othree/html5.vim',
    ft = { 'html' },
  },
  {
    name = 'vim-javascript',
    src = 'pangloss/vim-javascript',
    ft = { 'javascript' },
  },
  {
    name = 'emmet-vim',
    src = 'mattn/emmet-vim',
    ft = { 'htmlangular', 'html', 'scss', 'css', 'tsx', 'razor' },
    init = function()
      require 'my_plugin.emmet'
    end,
  },
  {
    name = 'vim-lua',
    src = 'tbastos/vim-lua',
    ft = { 'lua' },
  },
  {
    name = 'nvim-dap',
    src = 'mfussenegger/nvim-dap',
    ft = { 'cs', 'javascript' },
    config = function()
      if not vim.wo.diff then
        require 'my_plugin.nvim-dap.nvim-dap'.configure()
      end
    end,
  },
  {
    name = 'blamer',
    src = 'z4p5a9/blamer.nvim',
    ft = {
      'javascript',
      'typescript',
      'json',
      'markdown',
      'html',
      'css',
      'scss',
      'lua',
      'sh',
    },
    config = function()
      vim.g.blamer_enabled = 1
    end,
  },
  {
    name = 'telescope',
    src = 'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-fzf-native.nvim',
    },
    config = function()
      if not vim.wo.diff then
        require 'my_plugin.telescope'
      end
    end,
  },
}

P.add(pack)
