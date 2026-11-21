-- Thin plugin-spec layer on top of Neovim's built-in `vim.pack`.
-- Accepts specs of the form { name, src, ft?, pattern?, init?, config? }:
--   - `src` is a "user/repo" GitHub shorthand, expanded to a full URL.
--   - a spec with `ft` is installed lazily, once, on the first matching
--     FileType event.
--   - a spec with `pattern` is installed lazily, once, the first time a
--     matching command is used (CmdUndefined).
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

-- Installs/loads a single lazy spec. Builds a fresh table so the caller's
-- spec (and its shorthand `src`) is never mutated.
local function load_lazy(spec)
  if type(spec.init) == 'function' then
    spec.init()
  end
  vim.pack.add({ { src = src_to_github_url(spec.src), name = spec.name } }, M.lazy_loaded_opts)
  if type(spec.config) == 'function' then
    spec.config()
  end
end

local function create_auto_cmd(spec)
  vim.api.nvim_create_autocmd('FileType', {
    pattern = spec.ft,
    once = true,
    group = vim.api.nvim_create_augroup('FileTypePattern' .. spec.name, { clear = true }),
    callback = function()
      load_lazy(spec)
    end,
  })
end

local function create_auto_cmd_by_pattern(spec)
  vim.api.nvim_create_autocmd('CmdUndefined', {
    pattern = spec.pattern,
    once = true,
    group = vim.api.nvim_create_augroup('CmdUndefinedPack' .. spec.name, { clear = true }),
    callback = function()
      load_lazy(spec)
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

return M
