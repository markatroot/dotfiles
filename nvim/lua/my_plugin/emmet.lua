-- emmet-vim settings (see init.lua for the plugin's filetype-triggered load).
local g = vim.g

g.user_emmet_install_global = 1
g.user_emmet_expandabbr_key = '<c-l>'
g.user_emmet_next_key = '<c-j>'
g.user_emmet_prev_key = '<c-k>'
g.emmet_html5 = 1
g.user_emmet_settings = {
  ['html'] = {
    ['comment_type'] = 'lastonly'
  }
}
