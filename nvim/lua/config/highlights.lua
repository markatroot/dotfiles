-- Custom highlight overrides applied on top of the active colorscheme.
-- M.load() is called from config.nvim's M.load_highlights, which is wired to
-- the ColorScheme autocmd in config.theme, so these always win over the
-- theme's defaults whenever the colorscheme (re)loads.
local U = require 'config.utils'
local M = {}
local colors_helper = require('onedarkpro.helpers')
local colors = colors_helper.get_colors()

local function set_hl(name, value)
  vim.api.nvim_set_hl(0, name, value)
end

function M.load()
  set_hl('LspSignatureActiveParameter', { underline = true, bold = true })
  set_hl('WinSeparator', { bg = 'none', fg = 'gray' })

  local keyword_hl = vim.api.nvim_get_hl(0, { name = 'Keyword' })

  -- Statusline / tabline items
  set_hl('MyStatusItemDiagInfo', { bg = colors.blue, fg = colors.bg })
  set_hl('MyStatusItemDiagHint', { bg = colors.purple, fg = colors.bg })
  set_hl('MyStatusItemDiagWarn', { bg = colors.yellow, fg = colors.bg })
  set_hl('MyStatusItemDiagError', { bg = colors.red, fg = colors.bg })
  set_hl('MyStatusItem', { bg = keyword_hl.fg, fg = colors.bg })
  set_hl('StatusLineNC', { bg = 'NONE', ctermfg = 'NONE' })
  set_hl('StatusLine', { bg = 'NONE', ctermfg = 'NONE' })
  set_hl('TabLineSel', { bg = keyword_hl.fg, fg = colors.bg })

  -- Diagnostics
  set_hl('DiagnosticUnderlineError', { undercurl = true, sp = 'red' })
  set_hl('DiagnosticUnderlineWarn', { undercurl = true, sp = 'yellow' })
  set_hl('DiagnosticUnderlineHint', { undercurl = true, sp = 'blue' })
  set_hl('DiagnosticUnderlineInfo', { undercurl = true, sp = 'blue' })

  -- Float / border colors
  set_hl('NeoTreeFloatBorder', { fg = U.border_color, bg = 'NONE' })
  set_hl('NeoTreeFloatTitle', { fg = U.border_color, bg = 'NONE' })
  set_hl('TelescopeBorder', { fg = U.border_color, bg = 'NONE' })
  set_hl('TelescopeTitle', { fg = U.border_color, bg = 'NONE' })
  set_hl('FloatBorder', { fg = U.border_color, bg = 'NONE' })

  set_hl('CursorLine', { bg = colors_helper.lighten('bg', 7, 'onedark') })

  -- Separator colors
  set_hl('WinSeparator', { fg = '#caa5f7', bold = false })
  set_hl('EndOfBuffer', { fg = '#caa5f7', bold = false })
  set_hl('MsgSeparator', { fg = '#caa5f7', bold = false })
end

return M
