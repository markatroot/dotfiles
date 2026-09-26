-- Core Neovim options (indentation, UI chrome, search, etc.).
-- mapleader is set in config.mapping, which loads before this file.
vim.cmd('filetype plugin indent on')

-- Files / swap
vim.opt.swapfile = false
vim.opt.dir = '/home/mark/.mark/config/nvim/swap'

-- UI chrome
vim.opt.laststatus = 3
vim.opt.mouse = 'v'
vim.opt.title = true
vim.opt.showcmd = false
vim.opt.showtabline = 1
vim.opt.number = false
vim.opt.fillchars = {
  eob = ' ',
  horiz = '━',
  horizup = '┻',
  horizdown = '┳',
  vert = '┃',
  vertleft = '┫',
  vertright = '┣',
  verthoriz = '╋',
}

-- Indentation
vim.opt.tabstop = 2         -- Number of spaces that a tab counts for
vim.opt.shiftwidth = 2      -- Number of spaces to use for indentation
vim.opt.softtabstop = 2     -- Number of spaces to use for editing
vim.opt.expandtab = true    -- Convert tabs to spaces
vim.o.smarttab = true

-- Search / cursor
vim.o.hlsearch = true
vim.o.cursorline = true
vim.o.incsearch = true

-- Misc
vim.o.background = 'dark'
vim.o.encoding = 'utf-8'
vim.o.updatetime = 500

-- Popup menu / completion
vim.o.pumheight = 15
vim.o.pumborder = 'rounded'
vim.o.pummaxwidth = 40
vim.o.winborder = 'rounded'
vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }
