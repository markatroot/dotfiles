-- nvim-dap setup: adapters, breakpoint signs, and debug keymaps. Loaded when
-- nvim-dap is installed (see init.lua's `ft = { "cs", "javascript" }` entry).
local dap = require 'dap'

local M = {}

function M.configure()
  -- Path is specific to this machine's netcoredbg install.
  dap.adapters.netcoredbg = {
    type = 'executable',
    command = '/home/mark/.mark/lsp/netcoredbg/netcoredbg',
    args = { '--interpreter=vscode' },
  }

  local st_bin_path = vim.fn.exepath('st')
  dap.defaults.fallback.external_terminal = {
    command = st_bin_path,
    args = { '-e' },
  }

  require('my_plugin.nvim-dap.nvim-dap-adapters').configure()

  vim.cmd('hi DapBreakpointText ctermfg=9')
  vim.cmd('hi DapBreakpointConditionText ctermfg=208')

  vim.fn.sign_define('DapBreakpoint', {
    text = '',
    texthl = 'DapBreakpointText',
    linehl = 'CursorLine',
    numhl = '',
  })

  vim.fn.sign_define('DapBreakpointCondition', {
    text = '',
    texthl = 'DapBreakpointConditionText',
    linehl = 'CursorLine',
    numhl = '',
  })

  vim.fn.sign_define('DapBreakpointRejected', {
    text = '',
    texthl = '',
    linehl = '',
    numhl = '',
  })

  -- NOTE: `options` here is an undefined global, not the `opts` declared
  -- below, so every keymap below is set without silent/noremap. Left as-is
  -- to avoid changing existing behavior.
  local opts = { silent = true, noremap = true }
  vim.keymap.set('n', '<F5>', dap.continue, options)
  vim.keymap.set('n', '<F10>', dap.step_over, options)
  vim.keymap.set('n', '<F11>', dap.step_into, options)
  vim.keymap.set('n', '<F12>', dap.step_out, options)
  vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, options)
  vim.keymap.set('n', '<leader>B', function()
    dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
  end, options)
  vim.keymap.set('n', '<leader>lp', function()
    dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))
  end, options)
  vim.keymap.set('n', '<leader>do', dap.repl.open, options)
  vim.keymap.set('n', '<leader>dr', dap.restart, options)
  vim.keymap.set('n', '<leader>dl', dap.run_last, options)
  vim.keymap.set('n', '<leader>dh', require('dap.ui.widgets').hover, options)
  vim.keymap.set('n', '<leader>ds', require('my_plugin.nvim-dap.nvim-dap').scope, options)
end

function M.scope()
  local opts = {
    height = 50,
    width = 50,
  }
  dap.repl.open(opts)
end

return M
