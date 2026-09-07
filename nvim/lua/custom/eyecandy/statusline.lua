-- Custom statusline: shows mode, filename, LSP status/diagnostics, and
-- cursor position. Set via 'statusline' on WinEnter/WinLeave so the active
-- and inactive windows can render differently.
local E = require 'custom.eyecandy.eyecandy'
local C = vim.cmd

local function get_lsp_diag_count(severity, bufnr)
  bufnr = bufnr or 0
  return #vim.diagnostic.get(bufnr, { severity = severity })
end

-- Unused now that my_statusline renders via vim.lsp.status()/
-- vim.diagnostic.status() instead; kept for reference.
local function get_error(highlight, bufnr)
  local err = get_lsp_diag_count(vim.diagnostic.severity.ERROR, bufnr)
  if err == 0 then
    return ''
  end
  return '%#' .. highlight .. '# ' .. err .. ' %*'
end

local function get_warn(highlight, bufnr)
  local warn = get_lsp_diag_count(vim.diagnostic.severity.WARN, bufnr)
  if warn == 0 then
    return ''
  end
  return '%#' .. highlight .. '# ' .. warn .. ' %*'
end

local function get_info(highlight, bufnr)
  local info = get_lsp_diag_count(vim.diagnostic.severity.INFO, bufnr)
  if info == 0 then
    return ''
  end
  return '%#' .. highlight .. '# ' .. info .. ' %*'
end

local function get_hint(highlight, bufnr)
  local hint = get_lsp_diag_count(vim.diagnostic.severity.HINT, bufnr)
  if hint == 0 then
    return ''
  end
  return '%#' .. highlight .. '# ' .. hint .. ' %*'
end

-- Unused: an alternate {text, hl} pairing for mode(), superseded by the
-- `modes` table below; kept for reference.
local mode_info_normal = { text = 'Normal', hl = 'Normal' }
local mode_info_visual = { text = 'Visual', hl = 'Visual' }
local mode_info_insert = { text = 'Insert', hl = 'IncSearch' }
local mode_info_replace = { text = 'Replace', hl = 'Substitute' }
local mode_info_command = { text = 'Command-line', hl = 'TabLine' }
local mode_info_hitenter = { text = 'Hit-enter', hl = 'TabLineFill' }

local modes = {
  ['n'] = 'Normal', ['no'] = 'Normal', ['nov'] = 'Normal', ['niR'] = 'Normal',
  ['niV'] = 'Normal', ['nt'] = 'Normal', ['ntT'] = 'Normal',
  ['v'] = 'Visual', ['vs'] = 'Visual', ['V'] = 'Visual', ['Vs'] = 'Visual',
  ['CTRL-V'] = 'Visual', ['CTRL-Vs'] = 'Visual',
  ['i'] = 'Insert', ['ic'] = 'Insert', ['ix'] = 'Insert',
  ['R'] = 'Replace', ['Rc'] = 'Replace', ['Rx'] = 'Replace',
  ['Rv'] = 'Replace', ['Rvc'] = 'Replace', ['Rvx'] = 'Replace',
  ['c'] = 'Command', ['rm'] = 'Command',
  ['r'] = 'Hit-enter',
}

local function mode()
  return modes[vim.fn.mode()] or ''
end

-- Unused: kept as reference for picking a highlight based on the worst
-- diagnostic severity present in the buffer.
local function get_right_separator_hl()
  if get_lsp_diag_count(vim.diagnostic.severity.ERROR) ~= 0 then
    return 'MyStatusItemDiagError'
  elseif get_lsp_diag_count(vim.diagnostic.severity.WARN) ~= 0 then
    return 'MyStatusItemDiagWarn'
  elseif get_lsp_diag_count(vim.diagnostic.severity.INFO) ~= 0 then
    return 'MyStatusItemDiagInfo'
  elseif get_lsp_diag_count(vim.diagnostic.severity.HINT) ~= 0 then
    return 'MyStatusItemDiagHint'
  else
    return nil
  end
end

function _G.my_statusline(inactive)
  if inactive == 0 then
    return '%#MyStatusItem# %y %t' .. E.right_separator .. '%*'
  end
  return '%#MyStatusItem# ' .. mode() .. ' '
    .. '%#MyStatusItem#%y %t %*' -- filename
    .. '%='
    .. '%#MyStatusItem#' .. vim.lsp.status() .. '%*'
    .. vim.diagnostic.status()
    .. '%#PmenuSel# %c/%l ' -- line number
    .. ' %p %*' -- page percentage
end

vim.api.nvim_create_autocmd({ 'WinEnter', 'BufEnter' }, {
  pattern = { '*' },
  callback = function(event)
    vim.opt_local.statusline = '%!v:lua.my_statusline(1)'
  end,
})

vim.api.nvim_create_autocmd({ 'WinLeave', 'BufLeave' }, {
  pattern = { '*' },
  callback = function(event)
    vim.opt_local.statusline = '%!v:lua.my_statusline(0)'
  end,
})

-- These ex-command autocmds are registered after the vim.api pair above, for
-- the same events, so they always run last and win: every window ends up
-- with `my_statusline()` (nil) or `my_statusline(1)` — never the `(0)` short
-- form the vim.api pair sets. In effect all windows render the full
-- statusline today. Left as-is to avoid changing visible behavior.
C('autocmd WinEnter,BufEnter * setlocal statusline=%!v:lua.my_statusline()')
C('autocmd WinLeave,BufLeave * setlocal statusline=%!v:lua.my_statusline(1)')
