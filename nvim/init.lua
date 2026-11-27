-- Entry point loaded by sysinit.vim. Declares plugins for Neovim's built-in
-- `vim.pack` manager (see lua/custom/pack/pack.lua) and installs them.
local P = require('custom.pack.pack')

-- Rebuild telescope-fzf-native's C library whenever it's installed/updated.
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local d = ev.data
    if d.spec.name == 'telescope-fzf-native' and (d.kind == 'install' or d.kind == 'update') then
      vim.system({ 'make' }, { cwd = d.path })
    end
  end,
})

local pack = {
  -- {
  --   name = 'tiny-cmdline.nvim',
  --   src = 'rachartier/tiny-cmdline.nvim',
  --   config = function () 
  --     require 'my_plugin.tiny-cmdline'
  --   end
  -- },
  {
    name = 'tree-sitter-manager.nvim',
    src = 'romus204/tree-sitter-manager.nvim',
    -- ft = {
    --   'javascript',
    --   'typescript',
    --   'lua',
    --   'html',
    --   'css',
    --   'scss',
    --   'bash',
    --   'sh',
    --   'qml',
    -- },
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
    config = function()
      -- require 'custom.cmdline.cmdline'
    end
  },
  {
    name = 'mini-surround',
    src = 'nvim-mini/mini.surround',
    config = function()
      -- Deferred until after the first redraw; the mappings aren't needed
      -- before then.
      vim.schedule(function()
        require 'my_plugin.mini-surround'
      end)
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
    -- Loaded on first :Neotree (e.g. the <C-i> toggle). Note: until then it
    -- won't hijack netrw for `nvim <dir>`.
    pattern = 'Neotree',
    config = function()
      require 'my_plugin.neo-tree'
    end,
  },
  {
    name = 'formatter',
    src = 'mhartington/formatter.nvim',
    -- Loaded on first :Format (bound to <leader>p in plugin/lsp.lua).
    pattern = { 'Format', 'FormatWrite', 'FormatLock', 'FormatWriteLock' },
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
      'htmlangular',
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
    config = function()
      if not vim.wo.diff then
        require 'my_plugin.telescope'
      end
    end,
  },
  {
    name = "markview",
    src = "OXY2DEV/markview.nvim",
    ft = { 'markdown' }
  },
  {
    name = "colorizer",
    src = "catgoose/nvim-colorizer.lua",
    pattern = "ColorizerToggle",
    config = function()
      require 'my_plugin.nvim-colorizer'
    end
  }
}

P.add(pack)
