-- Custom tabline: renders one label per tab, with the active tab highlighted.
local utils = require 'config.utils'
local fn = vim.fn
local E = require 'custom.eyecandy.eyecandy'

local function get_tab_label(index)
  local buflist = fn.tabpagebuflist(index)
  local winnr = fn.tabpagewinnr(index)
  local bufnr = buflist[winnr]
  local buftype = fn.getbufvar(bufnr, '&filetype')

  if buftype == 'help' then
    return ' Help '
  elseif buftype == 'quickfix' then
    return ' Quickfix '
  elseif buftype == 'netrw' then
    return ' Netrw '
  end

  local bufname = fn.bufname(bufnr)
  if bufname == '' then
    return ' [No Name] '
  elseif utils.starts_with(bufname, 'term') then
    -- BUG: missing '=' means this never actually captures the match result,
    -- so any terminal buffer is unconditionally labeled 'Fzf'. Left as-is.
    local _, fzf bufname:match('(.+)#(.+)')
    return ' Fzf '
  end

  return ' ' .. fn.fnamemodify(bufname, ':t') .. ' '
end

-- The active tab used to get a separator-glyph highlight wrapped around it
-- (see E.right_separator/left_separator); those inserts were commented out
-- upstream and have been dropped here since they were already no-ops.
local function render_tabline()
  local tabline = ''
  local tab_count = fn.tabpagenr('$')
  local current_tab = fn.tabpagenr()

  for i = 1, tab_count do
    local tab_is_active = i == current_tab

    tabline = tabline .. (tab_is_active and '%#TabLineSel#' or '%#TabLine#')
    tabline = tabline .. get_tab_label(i)

    if (i + 1) ~= current_tab and not tab_is_active then
      tabline = tabline .. E.left_group_separator
    end
  end

  return tabline .. '%T%#TabLineFill#%='
end

function _G.my_tabline()
  return render_tabline()
end

vim.o.tabline = '%!v:lua.my_tabline()'
