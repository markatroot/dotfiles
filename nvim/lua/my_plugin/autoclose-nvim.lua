-- Unused: autoclose.nvim is not in the plugin list (init.lua / lua/custom/pack),
-- so this config is never loaded. Kept for reference.
require('autoclose').setup({
  keys = {
    ['('] = { escape = false, close = true, pair = '()' },
    ['['] = { escape = false, close = true, pair = '[]' },
    ['{'] = { escape = false, close = true, pair = '{}' },

    ['>'] = { escape = true, close = false, pair = '<>' },
    [')'] = { escape = true, close = false, pair = '()' },
    [']'] = { escape = true, close = false, pair = '[]' },
    ['}'] = { escape = true, close = false, pair = '{}' },

    ['"'] = { escape = true, close = true, pair = '""' },
    ["'"] = { escape = true, close = true, pair = "''" },
    ['`'] = { escape = true, close = true, pair = '``' },
  },
})

