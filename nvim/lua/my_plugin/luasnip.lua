-- Unused: LuaSnip isn't in the plugin list (init.lua / lua/custom/pack), and
-- this module isn't required anywhere. Kept for reference.
local ls = require 'luasnip'
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

ls.add_snippets('typescript', {
  s('imp', {
    t('import { '),
    i(2),
    t(" } from '"),
    i(1),
    t("';"),
    i(3),
  }),
})

local function attach_mapping(bufnr)
  local opts = { buffer = bufnr }
  vim.keymap.set('i', '<c-i>', ls.expand , opts)
  vim.keymap.set('i', '<c-h>', function()
    ls.jump(-1)
  end, opts)
  vim.keymap.set('i', '<c-l>', function()
    ls.jump(1)
  end, opts)
end

ls.setup({
  load_ft_func = function(bufnr)
    attach_mapping(bufnr)
    return { 'typescript' }
  end,
})
