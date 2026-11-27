-- LSP setup: buffer-local keymaps applied on attach/detach, per-server
-- registration (lua/lsp/servers/*.lua), and diagnostic/statusline display.
-- Files under plugin/ are auto-sourced by Neovim on startup, so this runs
-- without an explicit `require`.
local M = {}

-- Returns a function that requires `mod` and calls `fn` on demand, so the
-- module (telescope, lsp.codeaction, ...) is only loaded on first keypress.
local function lazy(mod, fn)
  return function(...)
    return require(mod)[fn](...)
  end
end

-- Buffer-local keymaps applied to every LSP-attached buffer (see the
-- LspAttach/LspDetach autocmds below).
M.lsp_mappings = {
  { mode = 'n', key = '<c-j>', fn = lazy('lsp.diagnostic', 'goto_next') },
  { mode = 'n', key = '<c-k>', fn = lazy('lsp.diagnostic', 'goto_prev') },
  { mode = 'n', key = '<leader>s', fn = lazy('lsp.codeaction', 'code_action') },
  { mode = 'n', key = '<leader>rn', fn = lazy('lsp.text_document', 'rename') },
  { mode = 'n', key = 'gd', fn = lazy('my_plugin.telescope', 'lsp_definitions') },
  { mode = 'n', key = 'K', fn = function() vim.lsp.buf.hover() end },
  { mode = 'n', key = 'gi', fn = lazy('my_plugin.telescope', 'lsp_implementations') },
  { mode = 'n', key = 'gr', fn = lazy('my_plugin.telescope', 'lsp_references') },
  { mode = 'n', key = 'gs', fn = lazy('my_plugin.telescope', 'lsp_document_symbols') },
  { mode = 'n', key = '<leader>o', fn = lazy('lsp.codeaction', 'organize_imports') },
  { mode = 'i', key = '<c-k>', fn = function() vim.lsp.buf.signature_help() end },
  { mode = 'n', key = '<leader>f', fn = lazy('lsp.codeaction', 'code_format') },
  { mode = 'n', key = '<leader>p', fn = '<cmd>Format<cr>' },
  {
    mode = 'n',
    key = '<leader>rf',
    fn = function()
      if vim.bo.filetype == 'typescript' then
        require 'lsp.codeaction'.rename_file()
      end
    end
  },
  { mode = 'n', key = '<leader>ai', fn = lazy('lsp.codeaction', 'add_missing_imports') },
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
  { name = 'tsserver', attach = true },
  { name = 'qmlls', attach = true },
  { name = 'angularls', attach = false }
}

-- vim.lsp.enable() already starts servers only for matching filetypes, so
-- register them once. Deferred to the first file read so a bare `nvim`
-- never loads vim.lsp. BufReadPre/BufNewFile fire before that buffer's
-- FileType, so the first file still gets its server attached.
vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  group = vim.api.nvim_create_augroup('LspEnableServers', { clear = true }),
  once = true,
  callback = function()
    for _, server in ipairs(SERVERS) do
      if server.attach then
        vim.lsp.config(server.name, require('lsp.servers.' .. server.name))
        vim.lsp.enable(server.name)
      end
    end
  end,
})

-- Global diagnostic display; set once rather than on every attach.
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
        format = format .. (strFormat):format('MyStatusItemDiagError', error, '')
      end

      local warn = counts[vim.diagnostic.severity.WARN]
      if warn ~= nil and warn ~= 0 then
        format = format .. (strFormat):format('MyStatusItemDiagWarn', warn, '')
      end

      local info = counts[vim.diagnostic.severity.INFO]
      if info ~= nil and info ~= 0 then
        format = format .. (strFormat):format('MyStatusItemDiagInfo', info, '')
      end

      -- NOTE: uses the Info highlight group here, not a Hint one; left as-is.
      local hint = counts[vim.diagnostic.severity.HINT]
      if hint ~= nil and hint ~= 0 then
        format = format .. (strFormat):format('MyStatusItemDiagInfo', hint, '')
      end
      return format
    end
  }
})

local cursorhold_group = vim.api.nvim_create_augroup('LspLineDiagnostics', { clear = true })

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('LspAttachGroup', {}),
  callback = function(ev)
    -- verbose LSP client logging, useful when debugging a server
    -- vim.lsp.log.set_level(vim.log.levels.DEBUG)

    local client = vim.lsp.get_client_by_id(ev.data.client_id)

    vim.lsp.inlay_hint.enable(false)
    vim.lsp.semantic_tokens.enable(false)

    local opt = { buffer = ev.buf }
    for _, value in ipairs(M.lsp_mappings) do
      vim.keymap.set(value.mode, value.key, value.fn, opt)
    end

    if client and client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = false })
    end

    -- Clear this buffer's autocmds first so multiple clients (or a client
    -- restart) don't stack duplicate CursorHold handlers.
    vim.api.nvim_clear_autocmds({ group = cursorhold_group, buffer = ev.buf })
    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
      group = cursorhold_group,
      buffer = ev.buf,
      callback = function(event)
        require 'lsp.diagnostic'.show_line_diagnostics(event.buf)
      end,
    })

    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
    vim.bo[ev.buf].formatexpr = 'v:lua.vim.lsp.formatexpr()'
  end,
})

vim.api.nvim_create_autocmd('LspDetach', {
  group = vim.api.nvim_create_augroup('LspDetachGroup', {}),
  callback = function(args)
    -- Keep keymaps/autocmds while another client is still attached.
    local remaining = vim.tbl_filter(function(c)
      return c.id ~= args.data.client_id
    end, vim.lsp.get_clients({ bufnr = args.buf }))
    if #remaining > 0 then
      return
    end

    for _, value in ipairs(M.lsp_mappings) do
      pcall(vim.keymap.del, value.mode, value.key, { buffer = args.buf })
    end
    vim.api.nvim_clear_autocmds({ group = cursorhold_group, buffer = args.buf })
  end,
})

vim.api.nvim_create_autocmd('LspProgress', {
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
