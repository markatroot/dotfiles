-- Custom statusline: shows mode, filename, LSP status/diagnostics, and
-- cursor position. With laststatus=3 there is a single global statusline,
-- so it is set once on 'statusline' instead of per window via autocmds.
local E = require 'custom.eyecandy.eyecandy'

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

-- `inactive == 0` renders a short form (only useful if laststatus ~= 3).
function _G.my_statusline(inactive)
  if inactive == 0 then
    return '%#MyStatusItem# %y %t' .. E.right_separator .. '%*'
  end
  return '%#MyStatusItem# ' .. mode() .. ' '
    .. '%#MyStatusItem#%y %t %*' -- filename
    .. '%='
    -- Don't force-load vim.lsp just to draw the statusline.
    .. '%#MyStatusItem#' .. (package.loaded['vim.lsp'] and vim.lsp.status() or '') .. '%*'
    .. vim.diagnostic.status()
    .. '%#PmenuSel# %c/%l ' -- line number
    .. ' %p %*' -- page percentage
end

vim.o.statusline = '%!v:lua.my_statusline(1)'
