-- Thin plugin-spec layer on top of Neovim's built-in `vim.pack`.
-- Accepts specs of the form { name, src, ft?, pattern?, init?, config? }:
--   - `src` is a "user/repo" GitHub shorthand, expanded to a full URL.
--   - a spec with `ft` is installed lazily via an autocmd on that filetype.
--   - a spec with `pattern` is installed lazily the first time a matching
--     command is used (CmdUndefined).
--   - everything else is installed eagerly via `vim.pack.add`.
-- In all cases `init` runs before install and `config` runs after.
local M = {}

M.lazy_loaded_opts = {
  load = true,
  confirm = true,
}

local function src_to_github_url(src)
  return 'https://github.com/' .. src
end

-- Unused helper (no current callers), kept for reference.
local function ft_to_pattern(file_types)
  local file_types_glob = {}
  for _, ft in ipairs(file_types) do
    table.insert(file_types_glob, '*.' .. ft)
  end
  return file_types_glob
end

local function create_auto_cmd(spec)
  vim.api.nvim_create_autocmd('FileType', {
    pattern = spec.ft,
    group = vim.api.nvim_create_augroup('FileTypePattern' .. spec.name, { clear = true }),
    callback = function(ev)
      if type(spec.init) == 'function' then
        spec.init()
      end
      spec.src = src_to_github_url(spec.src)
      vim.pack.add({ spec }, M.lazy_loaded_opts)
      if type(spec.config) == 'function' then
        spec.config()
      end
    end,
  })
end

local function create_auto_cmd_by_pattern(spec)
  vim.api.nvim_create_autocmd('CmdUndefined', {
    pattern = spec.pattern,
    group = vim.api.nvim_create_augroup('CmdUndefinedPack', { clear = false }),
    callback = function(ev)
      if type(spec.init) == 'function' then
        spec.init()
      end
      spec.src = src_to_github_url(spec.src)
      vim.pack.add({ spec }, M.lazy_loaded_opts)
      require(spec.name)
      if type(spec.config) == 'function' then
        spec.config()
      end
    end,
  })
end

function M.add(specs)
  local pack = {}
  for _, spec in ipairs(specs) do
    if spec.ft ~= nil then
      create_auto_cmd(spec)
    elseif spec.pattern ~= nil then
      create_auto_cmd_by_pattern(spec)
    else
      table.insert(pack, {
        src = src_to_github_url(spec.src),
        name = spec.name,
        data = {
          config = spec.config,
        },
      })
    end
  end

  vim.pack.add(pack)
  for _, p in ipairs(pack) do
    if p.data and type(p.data.config) == 'function' then
      p.data.config()
    end
  end
end

-- Unused (not passed to vim.pack anywhere), kept for reference.
M.opts = {
  load = function(spec, path)
    return true
  end,
}

return M
