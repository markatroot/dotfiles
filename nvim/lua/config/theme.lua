-- Colorscheme setup. onedarkpro is the active theme.
-- (catppuccin/onenord configs used to live here commented out as swap-in
-- alternatives; neither is in the init.lua pack list anymore, so they were
-- dropped rather than kept as stale reference config.)
require('onedarkpro').setup({
  plugins = {
    aerial = false,
    barbar = false,
    copilot = false,
    dashboard = false,
    diffview = false,
    ['flash.nvim'] = false,
    gitsigns = false,
    hop = false,
    indentline = false,
    leap = false,
    lsp_saga = false,
    lsp_semantic_tokens = false,
    marks = false,
    mini_indentscope = false,
    neo_tree = true,
    neotest = false,
    nvim_bqf = false,
    nvim_cmp = false,
    nvim_dap = false,
    nvim_dap_ui = false,
    nvim_hlslens = false,
    nvim_lsp = true,
    nvim_navic = false,
    nvim_notify = false,
    nvim_tree = false,
    nvim_ts_rainbow = false,
    nvim_ts_rainbow2 = false,
    op_nvim = false,
    packer = false,
    polygot = false,
    startify = false,
    telescope = true,
    toggleterm = false,
    treesitter = true,
    trouble = false,
    vim_ultest = false,
    which_key = false,
  }
})

-- NOTE: `lsp` is an undefined global here (always nil), so this creates the
-- autocmd with no group, same as omitting `group` entirely.
vim.api.nvim_create_autocmd('ColorScheme', {
  group = lsp,
  callback = require 'config.nvim'.load_highlights
})

vim.cmd('colorscheme onedark')
