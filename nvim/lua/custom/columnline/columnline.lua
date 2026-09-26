-- Not currently loaded anywhere (nothing `require`s this module), and `C`
-- below is never defined in this file, so it would error if it ever ran.
-- Left as-is: reference/WIP.
function _G.my_columnline(inactive)
  if inactive then
    vim.fn.nvim_buf_set_option(0, 'nonumber', '')
  end
end

C('autocmd WinEnter,BufEnter * setlocal columnline=%!v:lua.my_columnline()')
C('autocmd WinLeave,BufLeave * setlocal columnline=%!v:lua.my_columnline(1)')
