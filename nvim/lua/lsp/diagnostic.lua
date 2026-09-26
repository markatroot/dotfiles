-- Diagnostic navigation/float helpers used by the LspAttach keymaps in
-- plugin/lsp.lua.
local lsp_util = require 'vim.lsp.util'
local util = require 'lsp.utility'
local config_util = require 'config.utils'
local vim = vim
local api = vim.api
local fn = vim.fn
local M = {}

-- NOTE: `bufnr` here is an undefined global (always nil), same as the
-- `bufnr` passed to M.show_line_diagnostics from goto_next/goto_prev below.
-- vim.diagnostic.open_float defaults to the current buffer either way, so
-- this has no visible effect. Left as-is.
local float_opts = {
  bufnr = bufnr,
  scope = 'c',
  focus = false
}

-- NOTE: intentionally not `local` — this was a global in the original code
-- (declared inside a do-block that didn't actually scope it). Left as-is.
show_diagnostic_msg_timer = vim.loop.new_timer()

function M.show_line_diagnostics(bufnr, force)
  bufnr = bufnr or 0
  if force then
    show_diagnostic_msg_timer:stop()
    vim.diagnostic.open_float(float_opts)
    return
  end
  show_diagnostic_msg_timer:stop()
  show_diagnostic_msg_timer:start(500, 0, vim.schedule_wrap(function()
    vim.diagnostic.open_float(float_opts)
  end))
end

function M.goto_next()
  if #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR }) >= 1 then
    vim.diagnostic.jump({
      count = 1,
      severity = vim.diagnostic.severity.ERROR,
      float = false
    })
  else
    vim.diagnostic.jump({
      count = 1,
      float = false
    })
  end
  M.show_line_diagnostics(bufnr, true)
end

function M.goto_prev()
  if #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR }) >= 1 then
    vim.diagnostic.jump({
      count = -1,
      severity = vim.diagnostic.severity.ERROR,
      float = false
    })
  else
    vim.diagnostic.jump({
      count = -1,
      float = false
    })
  end
  M.show_line_diagnostics(bufnr, true)
end

function M.get_current_line_diags()
  local diagnostics = vim.diagnostic.get(0, {
    lnum = vim.fn.line('.') - 1
  })
  if #diagnostics == 0 then
    return {}
  end
  local diagnostic_user_data = {}
  for _, value in ipairs(diagnostics) do
    table.insert(diagnostic_user_data, value.user_data.lsp)
  end
  return diagnostic_user_data
end

return M
