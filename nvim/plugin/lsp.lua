-- LSP setup: buffer-local keymaps applied on attach/detach, per-server
-- registration (lua/lsp/servers/*.lua), and diagnostic/statusline display.
-- Files under plugin/ are auto-sourced by Neovim on startup, so this runs
-- without an explicit `require`.
local api = vim.api
local var = require 'lsp.var'
local U = require 'config.utils'
local M = {}

-- Buffer-local keymaps applied to every LSP-attached buffer (see the
-- LspAttach/LspDetach autocmds below).
M.lsp_mappings = {
  { mode = 'n', key = '<c-j>', fn = require 'lsp.diagnostic'.goto_next },
  { mode = 'n', key = '<c-k>', fn = require 'lsp.diagnostic'.goto_prev },
  { mode = 'n', key = '<leader>s', fn = require 'lsp.codeaction'.code_action },
  { mode = 'n', key = '<leader>rn', fn = require 'lsp.text_document'.rename },
  { mode = 'n', key = 'gd', fn = require 'my_plugin.telescope'.lsp_definitions },
  { mode = 'n', key = 'K', fn = vim.lsp.buf.hover },
  { mode = 'n', key = 'gi', fn = require 'my_plugin.telescope'.lsp_implementations },
  { mode = 'n', key = 'gr', fn = require 'my_plugin.telescope'.lsp_references },
  { mode = 'n', key = 'gs', fn = require 'my_plugin.telescope'.lsp_document_symbols },
  { mode = 'n', key = '<leader>o', fn = require 'lsp.codeaction'.organize_imports },
  { mode = 'i', key = '<c-k>', fn = vim.lsp.buf.signature_help },
  { mode = 'n', key = '<leader>f', fn = require 'lsp.codeaction'.code_format },
  {
    mode = 'n',
    key = '<leader>rf',
    fn = function()
      if vim.bo.filetype == 'typescript' then
        require 'lsp.codeaction'.rename_file()
      end
    end
  },
  {
    mode = 'n',
    key = '<leader>ai',
    fn = require 'lsp.codeaction'.add_missing_imports
  },
}

-- `attach = false` servers have a config module under lua/lsp/servers/ but
-- are not auto-enabled here (e.g. superseded by another server, or opt-in
-- only). See lua/lsp/servers/<name>.lua for each server's filetypes/settings.
local SERVERS = {
  { name = 'jsonls', attach = true },
  { name = 'csharp_ls', attach = true },
  -- { name = 'omnisharp', attach = true },
  { name = 'vtsls', attach = false },
  { name = 'somesass_ls', attach = false },
  { name = 'tsgo', attach = true },
  { name = 'qmlls', attach = true },
  { name = 'angularls', attach = false }
}

for _, server in ipairs(SERVERS) do
  local config = require('lsp.servers.' .. server.name)
  if server.attach then
    vim.api.nvim_create_autocmd('FileType', {
      pattern = config.filetypes,
      callback = function(args)
        vim.lsp.config(server.name, config)
        vim.lsp.enable(server.name)
      end,
    })
  end
end

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('LspAttachGroup', {}),
  callback = function(ev)
    -- verbose LSP client logging, useful when debugging a server
    vim.lsp.log.set_level(vim.log.levels.DEBUG)

    -- disable lsp highlight
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    client.server_capabilities.semanticTokensProvider = nil

    vim.lsp.inlay_hint.enable(false, {
      bufnr = ev.buf
    })

    local opt = { buffer = ev.buf }
    for _, value in pairs(M.lsp_mappings) do
      vim.keymap.set(value.mode, value.key, value.fn, opt)
    end

    if client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = false })
    end

    vim.diagnostic.config({
      signs = false,
      underline = true,
      update_in_insert = false,
      virtual_text = false,
      virtual_lines = false,
      float = true,
      status = {
        format = function(counts)
          local format = ''
          local strFormat = '%%#%s# %s %s '

          local error = counts[vim.diagnostic.severity.ERROR]
          if error ~= nil and error ~= 0 then
            format = format .. (strFormat):format('MyStatusItemDiagError', error, '')
          end

          local warn = counts[vim.diagnostic.severity.WARN]
          if warn ~= nil and warn ~= 0 then
            format = format .. (strFormat):format('MyStatusItemDiagWarn', warn, '')
          end

          local info = counts[vim.diagnostic.severity.INFO]
          if info ~= nil and info ~= 0 then
            format = format .. (strFormat):format('MyStatusItemDiagInfo', info, '')
          end

          -- NOTE: uses the Info highlight group here, not a Hint one; left as-is.
          local hint = counts[vim.diagnostic.severity.HINT]
          if hint ~= nil and hint ~= 0 then
            format = format .. (strFormat):format('MyStatusItemDiagInfo', hint, '')
          end
          return format
        end
      }
    })

    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
      callback = function(event)
        require 'lsp.diagnostic'.show_line_diagnostics(event.buf)
      end,
      buffer = ev.buf, -- Apply to the current buffer
    })

    vim.api.nvim_buf_set_option(ev.buf, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
    api.nvim_buf_set_option(ev.buf, 'formatexpr', 'v:lua.vim.lsp.formatexpr()')

    -- The rest of this callback only applies to the biome client; bail out
    -- for every other server attaching to the buffer.
    if client.name ~= 'biome' then
      return
    end

    -- Add this <leader> bound mapping so formatting the entire document is easier.
    vim.keymap.set('n', '<leader>p', function()
      vim.lsp.buf.format({
        bufnr = ev.buf,
        filter = function(fmt_ev)
          return fmt_ev.name == 'biome'
        end
      })
    end, opt)
  end,
})

vim.api.nvim_create_autocmd('LspDetach', {
  group = vim.api.nvim_create_augroup('LspDetachGroup', {}),
  callback = function(args)
    local opt = { buffer = args.buf }
    for _, value in pairs(M.lsp_mappings) do
      if vim.fn.exists(value.mode .. 'map ' .. value.key) == 1 then
        vim.keymap.del(value.mode, value.key, opt)
      end
    end
  end,
})

vim.api.nvim_create_autocmd('LspProgress', {
  buffer = 0,
  callback = function(ev)
    local value = ev.data.params.value
    vim.api.nvim_echo({ { value.message or 'done' } }, false, {
      id = 'lsp.' .. ev.data.params.token,
      kind = 'progress',
      source = 'vim.lsp',
      title = value.title,
      status = value.kind ~= 'end' and 'running' or 'success',
      percent = value.percentage,
    })
  end,
})

return M
