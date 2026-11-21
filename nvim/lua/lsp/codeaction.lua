-- Code-action helpers used by the LspAttach keymaps in plugin/lsp.lua.
local vim = vim
local diag = require 'lsp.diagnostic'
local input = require 'custom.menu.input'
local M = {}

function M.organize_imports()
  vim.lsp.buf.code_action({
    apply = true,
    context = { only = { 'source.organizeImports' } },
  })
end

function M.add_missing_imports()
  vim.lsp.buf.code_action({
    apply = true,
    context = { only = { 'source.addMissingImports.ts' }, diagnostics = {} },
  })
end

-- vim.lsp.buf.format() already sends the buffer's effective indent width
-- (shiftwidth/tabstop) and 'expandtab', so no formatting_options are needed.
function M.code_format()
  vim.lsp.buf.format()
end

-- Renames the current file on disk, then sends workspace/didRenameFiles so
-- servers that support it (vtsls) update imports that point at it.
function M.rename_file()
  local old_path = vim.api.nvim_buf_get_name(0)
  local old_name = vim.fs.basename(old_path)

  local callback = function(new_name)
    if not new_name or new_name == '' or new_name == old_name then
      return
    end
    local new_path = vim.fs.joinpath(vim.fs.dirname(old_path), new_name)
    vim.lsp.util.rename(old_path, new_path)

    local files = { { oldUri = vim.uri.from_fname(old_path), newUri = vim.uri.from_fname(new_path) } }
    for _, client in ipairs(vim.lsp.get_clients({ method = 'workspace/didRenameFiles' })) do
      client:notify('workspace/didRenameFiles', { files = files })
    end
  end

  input.show({
    title = ' Rename ' .. old_name .. ' to: ',
    default_value = old_name,
    callback = callback
  })
end

function M.code_action()
  local diagnostics = diag.get_current_line_diags()
  vim.lsp.buf.code_action({
    context = {
      ['diagnostics'] = diagnostics,
    },
    apply = true
  })
end

return M
