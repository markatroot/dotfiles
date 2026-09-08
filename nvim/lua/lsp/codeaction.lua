-- Code-action helpers used by the LspAttach keymaps in plugin/lsp.lua.
local vim = vim
local util = require 'config.utils'
local diag = require 'lsp.diagnostic'
local input = require 'custom.menu.input'
local M = {}

function M.import_module()
  local hovered_diag = diag.get_hovered_diag()
  if hovered_diag == nil or vim.tbl_isempty(hovered_diag) then
    return
  end
  local function callback(...)
    local _, _, result = ...
    if vim.tbl_isempty(result) or vim.tbl_isempty(result[1]) then return end
    -- Only accept an "add missing import" style action; this string match
    -- may not be accurate for every server.
    if string.match(result[1].title, 'Remove declaration for') then
      return
    end
    vim.lsp.util.apply_text_document_edit(result[1].arguments[1].documentChanges[1])
    hovered_diag = nil
  end
  local params = M.diagnostic_to_codeaction_req(hovered_diag)
  vim.lsp.buf_request(0, 'textDocument/codeAction', params, callback)
end

function M.get_fixes()
  local d = diag.get_current_line_diags()
  if d == nil then return end
  local diagnostics = {}
  table.insert(diagnostics, {
    range = {
      start = {
        line = d.lnum,
        character = d.col
      },
      ['end'] = {
        line = d.end_lnum,
        character = d.end_col
      }
    },
    message = d.message,
    severity = d.severity,
    source = d.source
  })
  local params = vim.lsp.util.make_range_params()
  params.context = { ['diagnostics'] = diagnostics }
  vim.lsp.buf.code_action(params)
end

function M.set_fixes_result(result, winnr)
  vim.g.fixes_result = result
  vim.g.fixes_result_winnr = winnr
end

function M.fix_result()
  if vim.g.fixes_result ~= nil then
    local index = vim.fn.line('.')
    local results = vim.g.fixes_result
    if results[index] and not vim.tbl_isempty(results[index]) then
      local result = results[index]
      local bufnr = nil
      if result.command ~= nil and util.ends_with(result.command.command, 'executeCodeAction') then
        bufnr = vim.uri_to_bufnr(result.command.arguments[1].Uri)
        vim.lsp.buf_request(bufnr, 'workspace/executeCommand', result.command)
      elseif result.command ~= nil and util.ends_with(result.command.command, 'applyWorkspaceEdit') then
        -- for ts lsp
        local code_changes = result.command.arguments[1].documentChanges[1]
        vim.lsp.util.apply_text_document_edit(code_changes)
        bufnr = vim.uri_to_bufnr(code_changes.textDocument.uri)
        -- focus on fixed window
        vim.fn.win_gotoid(vim.fn.get(vim.fn.win_findbuf(bufnr), 0))
      else
        -- print('response is not handle ' .. result.command)
      end
      -- close window
      vim.fn.win_gotoid(vim.fn.get(vim.fn.win_findbuf(bufnr), 0))
    end
  end
  vim.g.fixes_result = nil
  vim.g.fixes_result_winnr = nil
end

function M.organize_imports()
  vim.lsp.buf.code_action({
    apply = true,
    context = { only = { 'source.organizeImports' } },
  })
end

function M.add_missing_imports()
  local params = {
    command = 'typescript.fixAll',
    arguments = {
      vim.api.nvim_buf_get_name(0)
    },
    title = ''
  }
  vim.lsp.buf.execute_command(params)
end

function M.code_format()
  -- NOTE: `formatting_options` here refers to the misspelled local above
  -- (`fomatting_options`), so it's always nil and vim.lsp.buf.format() runs
  -- with its defaults. Left as-is.
  local fomatting_options = {
    tabSize = vim.o.tabstop
  }
  vim.lsp.buf.format({
    formatting_options = formatting_options
  })
end

function M.rename_file()
  local buf_filename = vim.fn.expand('%:t')

  local callback = function(buf_newfilename)
    if buf_filename == buf_newfilename then
      return
    end
    local sourceURI = vim.uri_from_bufnr(0)
    local targetURI = vim.fn.substitute(sourceURI, buf_filename, buf_newfilename, 'g')

    local params = {
      command = 'typescript.applyRenameFile',
      arguments = {
        {
          sourceUri = sourceURI,
          targetUri = targetURI,
        }
      }
    }
    vim.lsp.buf.execute_command(params)
    local full_path = vim.fn.expand('%:p')
    local new_full_path = vim.fn.substitute(full_path, buf_filename, buf_newfilename, 'g')
    vim.lsp.util.rename(full_path, new_full_path)
  end

  input.show({
    title = ' Rename ' .. buf_filename .. ' to: ',
    default_value = buf_filename,
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
