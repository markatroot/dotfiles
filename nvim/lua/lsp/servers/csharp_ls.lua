---@brief
---
--- https://github.com/razzmatazz/csharp-language-server
---
--- Language Server for C#.
---
--- csharp-ls requires the [dotnet-sdk](https://dotnet.microsoft.com/download) to be installed.
---
--- The preferred way to install csharp-ls is with `dotnet tool install --global csharp-ls`.

-- Decompiled / source-generated documents.
-- With the `metadataUris` capability enabled (below), go-to-definition on a
-- symbol from a compiled assembly (BCL, NuGet) returns a virtual
-- `csharp:/<project>/decompiled/<Symbol>.cs` URI. Without it, csharp-ls >= 0.21
-- returns no location at all ("No LSP Definitions found"). This BufReadCmd
-- fetches the source for such a URI via the custom `csharp/metadata` request.
vim.api.nvim_create_autocmd('BufReadCmd', {
  group = vim.api.nvim_create_augroup('CsharpLsMetadata', {}),
  pattern = 'csharp:/*',
  callback = function(ev)
    local buf = ev.buf
    local uri = vim.api.nvim_buf_get_name(buf)
    local client = vim.lsp.get_clients({ name = 'csharp_ls' })[1]
    if not client then
      vim.notify('csharp_ls: no running client for ' .. uri, vim.log.levels.WARN)
      return
    end

    local res, err = client:request_sync('csharp/metadata', { textDocument = { uri = uri } }, 10000, buf)
    if not res or res.err or not res.result or not res.result.source then
      vim.notify('csharp_ls: failed to load ' .. uri .. ': ' .. vim.inspect(err or (res and res.err)), vim.log.levels.ERROR)
      return
    end

    local lines = vim.split(res.result.source:gsub('\r\n', '\n'), '\n', { plain = true })
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].buftype = 'nofile'
    vim.bo[buf].swapfile = false
    vim.bo[buf].modified = false
    vim.bo[buf].modifiable = false
    vim.bo[buf].readonly = true
    vim.bo[buf].filetype = 'cs'
    -- Attach so gd/K/gr keep working from inside the decompiled source.
    vim.lsp.buf_attach_client(buf, client.id)
  end,
})

---@type vim.lsp.Config
return {
  cmd = function(dispatchers, config)
    return vim.lsp.rpc.start({ 'csharp-ls' }, dispatchers, {
      -- csharp-ls attempt to locate sln, slnx or csproj files from cwd, so set cwd to root directory.
      -- If cmd_cwd is provided, use it instead.
      cwd = config.cmd_cwd or config.root_dir,
      env = config.cmd_env,
      detached = config.detached,
    })
  end,
  -- Not `root_markers`: vim.fs.root/find match exact basenames only, so globs
  -- like '*.sln' never match. root_dir would then be nil and csharp-ls would
  -- start in nvim's cwd, so the loaded solution/project (and therefore what
  -- go-to-definition can see) depended on where nvim was opened.
  root_dir = function(bufnr, on_dir)
    local path = vim.api.nvim_buf_get_name(bufnr)
    if path == '' or path:match('^csharp:/') then
      return
    end
    local function find(pred)
      local hit = vim.fs.find(function(name)
        return pred(name)
      end, { path = vim.fs.dirname(path), upward = true, limit = 1 })[1]
      return hit and vim.fs.dirname(hit)
    end
    -- tier 1: nearest solution, searched all the way up
    -- tier 2: nearest project if there is no solution anywhere
    local root = find(function(n) return n:match('%.slnx?$') ~= nil end)
      or find(function(n)
        return n:match('%.csproj$') ~= nil or n == 'omnisharp.json' or n == 'function.json'
      end)
    if root then
      on_dir(root)
    end
  end,
  filetypes = { 'cs' },
  capabilities = {
    experimental = {
      csharp = { metadataUris = true },
    },
  },
  settings = {
    csharp = { useMetadataUris = true },
  },
  init_options = {
    AutomaticWorkspaceInit = true,
  },
  get_language_id = function(_, ft)
    if ft == 'cs' then
      return 'csharp'
    end
    return ft
  end,
}

