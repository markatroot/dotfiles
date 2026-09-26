-- Thin wrapper around nui.nvim's Input popup, used for one-line prompts
-- (e.g. LSP rename, code action input) across the config.
local Input = require 'nui.input'
local util = require 'config.utils'

local M = {}

function M.show(options)
  local popup_options = {
    position = '50%',
    size = 40,
    border = {
      style = util.border,
      text = {
        top = options.title,
        top_align = 'center',
      },
    },
    win_options = {
      winhighlight = 'Normal:Normal,FloatBorder:Normal',
    },
  }

  local input = Input(popup_options, {
    prompt = '> ',
    default_value = options.default_value or '',
    keymap = {
      close = { '<esc>', '<C-c>' },
    },
    on_submit = function(value)
      options.callback(value)
    end,
  })

  input:mount()
end

return M
