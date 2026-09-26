" Alternate entry point (nvim -u sysinit.vim): loads init.lua directly,
" bypassing the standard runtimepath init.lua discovery.
let custom_rtp = getenv("NVIM_RTP")
if custom_rtp !=# v:null
  execute 'lua dofile("' . custom_rtp . '/init.lua")'
endif

