-- Custom winbar: shows the filename in the active window, blank otherwise.
-- Skipped for floating windows (see the `relative ~= ""` guard below).
function _G.my_winbar(inactive)
  if inactive then
    return ''
  end
  return '%#MyStatusItem# %t %*'
end

vim.api.nvim_create_autocmd({ 'WinEnter', 'BufEnter' }, {
  pattern = '*',
  callback = function(event)
    if vim.api.nvim_win_get_config(0).relative ~= '' then return end
    vim.opt_local.winbar = my_winbar(true, event.buf)
  end,
})

vim.api.nvim_create_autocmd({ 'WinLeave', 'BufLeave' }, {
  pattern = '*',
  callback = function(event)
    if vim.api.nvim_win_get_config(0).relative ~= '' then return end
    vim.opt_local.winbar = my_winbar(false, event.buf)
  end,
})
