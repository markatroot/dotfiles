-- textDocument/rename helper used by the LspAttach keymaps in plugin/lsp.lua.
local input = require 'custom.menu.input'
local U = require 'config.utils'

local M = {}

-- Note: uses vim.ui.input rather than the `input` module required above
-- (the `input` parameter below shadows it).
function M.rename(args)
  vim.ui.input({ prompt = 'New name: ' }, function(input)
    if input == nil then
      return
    end
    vim.lsp.buf.rename(input, {
      filter = function(client)
        return true
      end
    })
  end)
end

return M
