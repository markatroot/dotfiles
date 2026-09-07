" Alternate entry point (nvim -u sysinit.vim): loads init.lua directly,
" bypassing the standard runtimepath init.lua discovery.
local custom_rtp = vim.fn.getenv("NVIM_RTP")
lua dofile(custom_rtp .. '/init.lua')

