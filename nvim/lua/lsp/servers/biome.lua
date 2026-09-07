-- Not in plugin/lsp.lua's SERVERS table (so vim.lsp.enable('biome') is never
-- called here), but the LspAttach callback there does special-case a client
-- named "biome" for the <leader>p format mapping -- presumably enabled by
-- whatever project this was set up for. Kept for reference.
local util = require 'lspconfig.util'

return {
  default_config = {
    cmd = { 'biome', 'lsp-proxy' },
    filetypes = {
      'javascript',
      'json',
      'jsonc',
      'typescript',
    },
    root_dir = util.root_pattern('biome.json', 'biome.jsonc'),
    root_markers = { 'biome.json', 'biome.jsonc' },
    single_file_support = false,
  },
  docs = {
    description = [[
https://biomejs.dev

Toolchain of the web. [Successor of Rome](https://biomejs.dev/blog/annoucing-biome).

```sh
npm install [-g] @biomejs/biome
```
]],
    default_config = {
      root_dir = [[root_pattern('biome.json', 'biome.jsonc')]],
    },
  },
}
