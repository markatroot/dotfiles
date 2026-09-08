-- Small helper library shared across the config (option/keymap setters,
-- table utilities, highlight lookups, debounce).
local M = {}

function M.starts_with(str, start)
  if str == nil then return false end
  return str:sub(1, #start) == start
end

function M.ends_with(str, ending)
  if str == nil then return false end
  return ending == '' or str:sub(-#ending) == ending
end

function M.get_table_keys(tbl)
  local keys = {}
  for k in pairs(tbl) do
    table.insert(keys, k)
  end
  return keys
end

function M.find_index_by_value(tbl, value)
  for i, v in ipairs(tbl) do
    if v == value then
      return i
    end
  end
  return 0
end

function M.includes(tab, val)
  for _, value in ipairs(tab) do
    if value == val then
      return true
    end
  end
  return false
end

function M.ternary(cond, t, f)
  if cond then
    return t
  else
    return f
  end
end

-- Iterates `tbl` in key order, passing each callback the current value plus
-- its neighbours and position: cb(value, next, prev, index, is_first, is_last)
function M.tbl_iter(tbl, cb)
  local keys = M.get_table_keys(tbl)
  for i, v in ipairs(keys) do
    local prev = nil
    local next = nil
    if i ~= 1 then
      prev = tbl[keys[i - 1]]
    end
    if i ~= #keys then
      next = tbl[keys[i + 1]]
    end
    cb(tbl[keys[i]], next, prev, i, i == 1, i == #keys)
  end
end

function M.string_split(s, delimitter)
  local t = {}
  for k, v in string.gmatch(s, delimitter) do
    t[k] = v
  end
  return t
end

-- Debugging helper: dumps a table to ./sample.json (relative to cwd).
function M.append_to_file(tbl)
  local file = io.open('sample.json', 'a')
  io.output(file)
  local content = vim.inspect(tbl)
  io.write(content)
  io.close(file)
end

local scopes = {
  o = vim.o,        -- global options
  b = vim.bo,       -- buffer options
  w = vim.wo,       -- window options
  l = vim.opt_local -- local options
}

-- NOTE: `scopes[scope][key] = value` below already errors on an invalid
-- scope, so the nil-check and its error message (which is itself missing a
-- `..` between key and the following string) can never actually run.
function M.set_opt(scope, key, value)
  scopes[scope][key] = value
  if scope ~= 'o' then scopes['o'][key] = value end
  if scopes[scope] == nil then
    -- print('Invalid option: ' .. key ' ' .. value)
    return
  end

  if scope == 'o' then
    vim.api.nvim_set_option(key, value)
  elseif scope == 'w' then
    vim.api.nvim_win_set_option(0, key, value)
  elseif scope == 'b' then
    vim.api.nvim_buf_set_option(0, key, value)
  end
end

-- M.map uses the legacy string-only keymap API; M.keymap wraps the modern
-- vim.keymap.set and additionally accepts function callbacks as `rhs`.
function M.map(mode, lhs, rhs, opts)
  local options = { noremap = true }
  if opts then options = vim.tbl_extend('force', options, opts) end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

function M.keymap(mode, lhs, rhs, opts)
  local options = { noremap = true }
  if opts then options = vim.tbl_extend('force', options, opts) end
  vim.keymap.set(mode, lhs, rhs, options)
end

local function get_color(group, attr)
  return vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID(group)), attr)
end

-- Debug helper: fetches a highlight group's attrs with colors as hex strings.
function M.get_hl_hex(name)
  local ok, hl = pcall(vim.api.nvim_get_hl_by_name, name, true)
  if not ok then
    return
  end
  for _, key in pairs({ 'foreground', 'background', 'special' }) do
    if hl[key] then
      hl[key] = string.format('#%06x', hl[key])
    end
  end
  return hl
end

function M.get_hi_value(group, what, mode)
  mode = mode or 'gui'
  return vim.fn.synIDattr(vim.api.nvim_get_hl_id_by_name(group), what, mode)
end

-- Rounded border spec, reused by float-heavy plugins (Telescope, Neo-tree, LSP floats).
M.border = {
  '╭', -- top-left corner
  '─', -- top edge
  '╮', -- top-right corner
  '│', -- right edge
  '╯', -- bottom-right corner
  '─', -- bottom edge
  '╰', -- bottom-left corner
  '│', -- left edge
}

M.border_color = '#cba6f7'

M.load_plugin_config = function(name)
  require('my_plugin.' .. name)
end

-- Debug helper: prints the highlight group under the cursor.
M.print_hl_under_cursor = function()
  -- print(vim.inspect(vim.api.nvim_get_hl(-1, {})))
end

-- Timers for M.debounce, keyed by the caller-supplied timer_key.
local timers = {}

--- Debounces a function.
-- Calls the function only after 'delay_ms' milliseconds have passed
-- without the debounced function being called again.
--
-- @param func (function) The function to debounce.
-- @param delay_ms (number) The debounce delay in milliseconds.
-- @param timer_key (string, optional) A unique key to identify this debounced function.
--                                     If not provided, a new timer will be created each time.
--                                     Using a key is crucial if you want to debounce the same
--                                     logical operation in multiple places or contexts.
-- @return (function) The debounced function.
function M.debounce(func, delay_ms, timer_key)
  local timer = timers[timer_key]
  if not timer then
    timer = vim.loop.new_timer()
    if timer_key then
      timers[timer_key] = timer
    end
  end

  return function(...)
    local args = { ... } -- Capture arguments to pass to the debounced function

    -- Stop any existing timer
    timer:stop()

    -- Start a new timer
    timer:start(delay_ms, 0, vim.schedule_wrap(function()
      -- Execute the original function when the timer finishes
      func(unpack(args))
    end))
  end
end

function M.clear_debounce_timer(timer_key)
  if timers[timer_key] then
    timers[timer_key]:close()
    timers[timer_key] = nil
  end
end

function M.clear_all_debounce_timers()
  for _, timer in pairs(timers) do
    timer:close()
  end
  timers = {}
end

return M
