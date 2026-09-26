-- Unused: not currently wired up as a keymap or plugin config entry point
-- (blamer.nvim's own config just sets vim.g.blamer_enabled, see init.lua).
-- Kept for reference: shows `git blame` for the current line in a float.
local M = {}

vim.g.blamer_show_in_insert_modes = 0

function M.blame()
  local file_full_path = vim.fn.expand('%:p')
  local linenr = vim.fn.line('.')
  -- `git blame` for this one line, then pull the "(author date" bit out of
  -- parens and reformat it as "author date ago".
  local cmd = 'git blame -L' .. linenr .. ',+1 ' .. file_full_path
    .. " -e | awk -F '[()]' '{print $2}' | awk '{print $1\" \" $2\" \" $3\" \" \"ago\"}' | tr '\n' ' '"
  local blame = vim.fn.system(cmd)
  vim.lsp.util.open_floating_preview({ 'Change made by ' .. blame }, nil, {})
end

return M
