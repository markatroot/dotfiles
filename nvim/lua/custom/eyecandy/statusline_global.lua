-- Alternate statusline bootstrap that reports focus/diagnostic events to ags
-- over a notification socket. Not required anywhere (custom.eyecandy.eyecandy
-- is used instead); kept as reference.
-- NOTE: the last two branches below check `event.name`, but
-- nvim_create_autocmd callbacks receive the event name in `event.event` (as
-- the first two branches correctly do), so those two branches never match.
local M = {}

local function send_notif(notif)
  vim.cmd('silent !ags request "nvim:' .. notif .. '"')
end

function M.initialize(opts)
  local events = { 'FocusGained', 'FocusLost', 'CursorHold', 'DiagnosticChanged', 'BufEnter' }
  vim.api.nvim_create_autocmd(events, {
    pattern = '*',
    callback = function(event)
      if event.event == 'FocusGained' then
        send_notif(vim.fn.getpid())
      elseif event.event == 'FocusLost' then
        send_notif('null')
      elseif event.name == 'CursorHold' then
        -- no-op
      elseif event.name == 'DiagnosticChanged' then
        send_notif(JSON.stringify(event.data.diagnostics))
      elseif event.name == 'BufEnter' then
        send_notif(JSON.stringify(event))
      end
    end,
  })
end

return M
