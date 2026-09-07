-- Pushes editor state (mode, diagnostics, tabs, filename) to an external
-- status bar via `ags request` (see the ags/ AGS/Astal shell config).
-- Unused: this module is never `require`d anywhere, and even if it were,
-- M.initialize is never called — none of this is currently wired up.
local U = require 'config.utils'
local M = {}

local function get_diagnostic(bufnr)
  if bufnr == nil or not vim.lsp.buf_is_attached(bufnr) then
    return 0, 0, 0, 0
  end
  local result = vim.diagnostic.count(bufnr, {
    severity = {
      vim.diagnostic.severity.ERROR,
      vim.diagnostic.severity.WARN,
      vim.diagnostic.severity.INFO,
      vim.diagnostic.severity.HINT,
    },
  })
  return result[vim.diagnostic.severity.ERROR] or 0,
    result[vim.diagnostic.severity.WARN] or 0,
    result[vim.diagnostic.severity.INFO] or 0,
    result[vim.diagnostic.severity.HINT] or 0
end

-- Returns the four diagnostic counts pre-stringified, ready to merge into an
-- `ags` payload table.
local function diagnostic_payload(bufnr)
  local error, warn, info, hint = get_diagnostic(bufnr)
  return {
    error = tostring(error),
    warn = tostring(warn),
    info = tostring(info),
    hint = tostring(hint),
  }
end

M.titlestring = ''
M.tabstring = ''

local function set_statusline(buf)
  local opts = {
    col = vim.fn.col('.'),
    line = vim.fn.line('.'),
  }
  local mode = vim.fn.mode()
  local error, warn, info, hint = get_diagnostic(buf)
  -- filename, filetype, mode, linenr, linecolumn, line percentage
  M.titlestring = 'Neovim:|' .. mode .. '|%t|%y|' .. opts.line .. '|%L|' .. opts.col .. '|' ..
    error .. '|' .. warn .. '|' .. info .. '|' .. hint

  if M.titlestring ~= vim.opt.titlestring:get() then
    vim.opt.titlestring = M.titlestring .. '|' .. M.tabstring
  end
end

local function get_name_by_tabid(tabid)
  local win = vim.api.nvim_tabpage_get_win(tabid)
  local buf = vim.api.nvim_win_get_buf(win)
  return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ':t') or '[No Name]'
end

local function get_tabline_items(bufnr)
  local pages = vim.api.nvim_list_tabpages()
  if #pages <= 1 then
    return {}
  end

  local tab_name_arr = {}
  for _, tab in ipairs(pages) do
    table.insert(tab_name_arr, get_name_by_tabid(tab))
  end

  return {
    active = vim.fn.tabpagenr(),
    items = tab_name_arr,
  }
end

-- Sends `table` (JSON-encoded) to the ags shell as an nvim status event.
local function notify_ags(table)
  local cmd = { 'ags', 'request', 'Neovim:' .. vim.json.encode(table) }
  vim.fn.jobstart(cmd)
end

local function debounce_set_statusline(buf)
  notify_ags({
    linenr = tostring(vim.fn.line('.')),
    columnnr = tostring(vim.fn.col('.')),
  })
end

local debounced_my_expensive_function = U.debounce(debounce_set_statusline, 500, 'cursor_moved_event')

local debounced_tab_changed = U.debounce(function(bufnr)
  notify_ags({ tabs = get_tabline_items(bufnr) })
end, 200, 'tab_changed')

local debounced_mode_changed = U.debounce(function()
  notify_ags({ mode = ':' .. vim.fn.mode() })
end, 500, 'tab_changed')

local function emit_exit_statuslinevalue()
  notify_ags({
    fileType = '',
    fileName = '',
    mode = '',
    error = '0',
    warn = '0',
    info = '0',
    hint = '0',
    linenr = '',
    columnnr = '',
    tabs = {},
  })
end

local function emit_initial_statuslinevalue(bufnr)
  bufnr = bufnr or 0
  local mode = vim.fn.mode()
  notify_ags(vim.tbl_extend('force', diagnostic_payload(bufnr), {
    fileType = vim.bo.filetype,
    fileName = vim.fn.expand('%:t'),
    mode = mode .. ':' .. mode,
    linenr = tostring(vim.fn.line('.')),
    columnnr = tostring(vim.fn.col('.')),
    tabs = get_tabline_items(bufnr),
  }))
end

function M.initialize()
  vim.api.nvim_create_autocmd('BufEnter', {
    group = vim.api.nvim_create_augroup('titlestring.filetype', { clear = false }),
    callback = function()
      notify_ags({
        fileType = vim.bo.filetype,
        fileName = vim.fn.expand('%:t'),
      })
    end,
  })

  vim.api.nvim_create_autocmd('ModeChanged', {
    group = vim.api.nvim_create_augroup('titlestring.modechanged', { clear = false }),
    callback = function()
      debounced_mode_changed()
    end,
  })

  -- Only 'DiagnosticChanged' is registered here, so `vim.fn.mode() ~= 'n'`
  -- is the only real guard — no need to also check args.event.
  vim.api.nvim_create_autocmd('DiagnosticChanged', {
    group = vim.api.nvim_create_augroup('titlestring.diagnostic', { clear = false }),
    callback = function(args)
      if vim.fn.mode() ~= 'n' then
        return
      end
      notify_ags(diagnostic_payload(args.buf))
    end,
  })

  vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI', 'CursorMovedC' }, {
    group = vim.api.nvim_create_augroup('titlestring.cursor', { clear = false }),
    callback = function(args)
      debounced_my_expensive_function(args.buf)
    end,
  })

  vim.api.nvim_create_autocmd({ 'VimEnter', 'FocusGained' }, {
    group = vim.api.nvim_create_augroup('titlestring.vimenter', { clear = false }),
    callback = function(args)
      vim.opt.titlestring = 'Neovim:'
      emit_initial_statuslinevalue(args.buf)
    end,
  })

  vim.api.nvim_create_autocmd('VimLeave', {
    group = vim.api.nvim_create_augroup('titlestring.vimleave', { clear = false }),
    callback = function()
      emit_exit_statuslinevalue()
    end,
  })

  local tab_events = { 'FocusGained', 'BufEnter', 'TabNewEntered', 'TabEnter', 'TabLeave', 'TabClosed' }
  vim.api.nvim_create_autocmd(tab_events, {
    group = vim.api.nvim_create_augroup('titlestring.events_tab', { clear = false }),
    callback = function(args)
      debounced_tab_changed(args.buf)
    end,
  })
end

return M
