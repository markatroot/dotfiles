-- Inkwell: a deep blue-black neovim colorscheme with warm, earthy accents
-- Install: save as ~/.config/nvim/colors/inkwell.lua, then :colorscheme inkwell

local M = {}

vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end
vim.o.background = "dark"
vim.o.termguicolors = true
vim.g.colors_name = "inkwell"

local c = {
  bg        = "#16181d",
  bg_alt    = "#1b1e24",
  bg_line   = "#1e2128",
  bg_float  = "#1b1e24",
  bg_sel    = "#2c313b",
  bg_status = "#262a32",
  border    = "#2f343e",
  fg        = "#d4d0c8",
  fg_dim    = "#6b7180",
  line_nr   = "#3a3f4b",
  comment   = "#5c6370",

  keyword   = "#e07a5f", -- terracotta
  func      = "#81b29a", -- sage
  string    = "#f2cc8f", -- wheat
  type      = "#8ecae6", -- sky
  number    = "#c9a0dc", -- lilac
  operator  = "#a8b0bd",

  error     = "#ef6461",
  warn      = "#f2cc8f",
  info      = "#8ecae6",
  hint      = "#81b29a",

  add       = "#81b29a",
  change    = "#8ecae6",
  delete    = "#ef6461",
  none      = "NONE",
}

local function hl(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

local groups = {
  -- Editor UI
  Normal         = { fg = c.fg, bg = c.bg },
  NormalNC       = { fg = c.fg, bg = c.bg },
  NormalFloat    = { fg = c.fg, bg = c.bg_float },
  FloatBorder    = { fg = c.border, bg = c.bg_float },
  FloatTitle     = { fg = c.keyword, bg = c.bg_float, bold = true },
  ColorColumn    = { bg = c.bg_line },
  Cursor         = { fg = c.bg, bg = c.fg },
  CursorLine     = { bg = c.bg_line },
  CursorColumn   = { bg = c.bg_line },
  CursorLineNr   = { fg = c.string, bold = true },
  LineNr         = { fg = c.line_nr },
  SignColumn     = { bg = c.bg },
  FoldColumn     = { fg = c.line_nr, bg = c.bg },
  Folded         = { fg = c.fg_dim, bg = c.bg_alt },
  VertSplit      = { fg = c.border },
  WinSeparator   = { fg = c.border },
  EndOfBuffer    = { fg = c.bg },
  NonText        = { fg = c.line_nr },
  Whitespace     = { fg = c.line_nr },
  SpecialKey     = { fg = c.line_nr },
  Visual         = { bg = c.bg_sel },
  VisualNOS      = { bg = c.bg_sel },
  Search         = { fg = c.bg, bg = c.string },
  IncSearch      = { fg = c.bg, bg = c.keyword },
  CurSearch      = { fg = c.bg, bg = c.keyword },
  Substitute     = { fg = c.bg, bg = c.error },
  MatchParen     = { fg = c.string, bg = c.bg_sel, bold = true },
  Pmenu          = { fg = c.fg, bg = c.bg_float },
  PmenuSel       = { fg = c.bg, bg = c.func },
  PmenuSbar      = { bg = c.bg_alt },
  PmenuThumb     = { bg = c.border },
  StatusLine     = { fg = c.fg, bg = c.bg_status },
  StatusLineNC   = { fg = c.fg_dim, bg = c.bg_alt },
  TabLine        = { fg = c.fg_dim, bg = c.bg_alt },
  TabLineFill    = { bg = c.bg_alt },
  TabLineSel     = { fg = c.fg, bg = c.bg, bold = true },
  WinBar         = { fg = c.fg_dim, bg = c.bg },
  WildMenu       = { fg = c.bg, bg = c.func },
  Directory      = { fg = c.type },
  Title          = { fg = c.keyword, bold = true },
  Question       = { fg = c.func },
  MoreMsg        = { fg = c.func },
  ModeMsg        = { fg = c.fg, bold = true },
  ErrorMsg       = { fg = c.error },
  WarningMsg     = { fg = c.warn },
  Conceal        = { fg = c.fg_dim },
  SpellBad       = { sp = c.error, undercurl = true },
  SpellCap       = { sp = c.warn, undercurl = true },
  SpellLocal     = { sp = c.info, undercurl = true },
  SpellRare      = { sp = c.number, undercurl = true },
  QuickFixLine   = { bg = c.bg_sel },

  -- Syntax
  Comment        = { fg = c.comment, italic = true },
  Constant       = { fg = c.number },
  String         = { fg = c.string },
  Character      = { fg = c.string },
  Number         = { fg = c.number },
  Boolean        = { fg = c.number },
  Float          = { fg = c.number },
  Identifier     = { fg = c.fg },
  Function       = { fg = c.func },
  Statement      = { fg = c.keyword },
  Conditional    = { fg = c.keyword },
  Repeat         = { fg = c.keyword },
  Label          = { fg = c.keyword },
  Operator       = { fg = c.operator },
  Keyword        = { fg = c.keyword },
  Exception      = { fg = c.keyword },
  PreProc        = { fg = c.keyword },
  Include        = { fg = c.keyword },
  Define         = { fg = c.keyword },
  Macro          = { fg = c.type },
  PreCondit      = { fg = c.keyword },
  Type           = { fg = c.type },
  StorageClass   = { fg = c.keyword },
  Structure      = { fg = c.type },
  Typedef        = { fg = c.type },
  Special        = { fg = c.type },
  SpecialChar    = { fg = c.number },
  Tag            = { fg = c.keyword },
  Delimiter      = { fg = c.operator },
  SpecialComment = { fg = c.comment, italic = true },
  Debug          = { fg = c.error },
  Underlined     = { underline = true },
  Error          = { fg = c.error },
  Todo           = { fg = c.bg, bg = c.string, bold = true },

  -- Treesitter
  ["@variable"]                 = { fg = c.fg },
  ["@variable.builtin"]         = { fg = c.type, italic = true },
  ["@variable.parameter"]       = { fg = c.fg, italic = true },
  ["@variable.member"]          = { fg = c.fg },
  ["@property"]                 = { fg = c.fg },
  ["@constant"]                 = { fg = c.number },
  ["@constant.builtin"]         = { fg = c.number },
  ["@module"]                   = { fg = c.type },
  ["@module.builtin"]           = { fg = c.type },
  ["@string"]                   = { fg = c.string },
  ["@string.escape"]            = { fg = c.number },
  ["@string.regexp"]            = { fg = c.number },
  ["@string.special"]           = { fg = c.number },
  ["@character"]                = { fg = c.string },
  ["@number"]                   = { fg = c.number },
  ["@boolean"]                  = { fg = c.number },
  ["@type"]                     = { fg = c.type },
  ["@type.builtin"]             = { fg = c.type },
  ["@type.definition"]          = { fg = c.type },
  ["@attribute"]                = { fg = c.type },
  ["@function"]                 = { fg = c.func },
  ["@function.builtin"]         = { fg = c.func },
  ["@function.call"]            = { fg = c.func },
  ["@function.method"]          = { fg = c.func },
  ["@function.method.call"]     = { fg = c.func },
  ["@constructor"]              = { fg = c.type },
  ["@operator"]                 = { fg = c.operator },
  ["@keyword"]                  = { fg = c.keyword },
  ["@keyword.function"]         = { fg = c.keyword },
  ["@keyword.return"]           = { fg = c.keyword },
  ["@keyword.import"]           = { fg = c.keyword },
  ["@keyword.operator"]         = { fg = c.keyword },
  ["@punctuation.delimiter"]    = { fg = c.operator },
  ["@punctuation.bracket"]      = { fg = c.fg },
  ["@punctuation.special"]      = { fg = c.operator },
  ["@comment"]                  = { link = "Comment" },
  ["@tag"]                      = { fg = c.keyword },
  ["@tag.attribute"]            = { fg = c.type, italic = true },
  ["@tag.delimiter"]            = { fg = c.operator },
  ["@markup.heading"]           = { fg = c.keyword, bold = true },
  ["@markup.strong"]            = { bold = true },
  ["@markup.italic"]            = { italic = true },
  ["@markup.link"]              = { fg = c.type, underline = true },
  ["@markup.raw"]               = { fg = c.string },
  ["@markup.list"]              = { fg = c.keyword },

  -- LSP semantic tokens
  ["@lsp.type.parameter"]       = { fg = c.fg, italic = true },
  ["@lsp.type.interface"]       = { fg = c.type },
  ["@lsp.type.namespace"]       = { fg = c.type },
  ["@lsp.type.enumMember"]      = { fg = c.number },
  ["@lsp.type.property"]        = { fg = c.fg },
  ["@lsp.typemod.variable.readonly"] = { fg = c.fg },

  -- Diagnostics
  DiagnosticError            = { fg = c.error },
  DiagnosticWarn             = { fg = c.warn },
  DiagnosticInfo             = { fg = c.info },
  DiagnosticHint             = { fg = c.hint },
  DiagnosticUnderlineError   = { sp = c.error, undercurl = true },
  DiagnosticUnderlineWarn    = { sp = c.warn, undercurl = true },
  DiagnosticUnderlineInfo    = { sp = c.info, undercurl = true },
  DiagnosticUnderlineHint    = { sp = c.hint, undercurl = true },
  DiagnosticVirtualTextError = { fg = c.error, bg = "#2a1d20" },
  DiagnosticVirtualTextWarn  = { fg = c.warn, bg = "#2a2620" },
  DiagnosticVirtualTextInfo  = { fg = c.info, bg = "#1c2630" },
  DiagnosticVirtualTextHint  = { fg = c.hint, bg = "#1d2724" },
  LspReferenceText           = { bg = c.bg_sel },
  LspReferenceRead           = { bg = c.bg_sel },
  LspReferenceWrite          = { bg = c.bg_sel, underline = true },
  LspInlayHint               = { fg = c.fg_dim, italic = true },

  -- Diff and git
  DiffAdd          = { bg = "#1d2a24" },
  DiffChange       = { bg = "#1c2530" },
  DiffDelete       = { bg = "#2c1d20" },
  DiffText         = { bg = "#26384a" },
  Added            = { fg = c.add },
  Changed          = { fg = c.change },
  Removed          = { fg = c.delete },
  GitSignsAdd      = { fg = c.add },
  GitSignsChange   = { fg = c.change },
  GitSignsDelete   = { fg = c.delete },

  -- Telescope
  TelescopeNormal         = { fg = c.fg, bg = c.bg_float },
  TelescopeBorder         = { fg = c.border, bg = c.bg_float },
  TelescopeTitle          = { fg = c.keyword, bold = true },
  TelescopeSelection      = { bg = c.bg_sel },
  TelescopeMatching       = { fg = c.string, bold = true },
  TelescopePromptPrefix   = { fg = c.keyword },

  -- Indent guides
  IblIndent  = { fg = "#23262d" },
  IblScope   = { fg = c.border },
}

function M.setup() 
  for group, opts in pairs(groups) do
    hl(group, opts)
  end

  -- Terminal colors
  local term = {
    c.bg_status, c.error, c.func, c.string, c.type, c.number, c.type, c.fg,
    c.fg_dim, c.error, c.func, c.string, c.type, c.number, c.type, "#ffffff",
  }
  for i, color in ipairs(term) do
    vim.g["terminal_color_" .. (i - 1)] = color
  end
end

return M
