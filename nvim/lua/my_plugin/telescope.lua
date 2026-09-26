-- Telescope setup + custom pickers, bound to <C-p>/<C-o>/etc below.
local telescope = require('telescope')
local M = {}

local mappings = {
  ['<C-p>'] = 'close',
  ['<C-k>'] = 'move_selection_previous',
  ['<C-j>'] = 'move_selection_next',
}

-- NOTE: `borderchars = M.border` below is always nil (this file's own `M`
-- table, not `config.utils`'s `U.border`), so Telescope falls back to its
-- default border. Left as-is.
telescope.setup({
  preview = false,
  defaults = {
    file_ignore_patterns = { 'node_modules', '@girs' },
    layout_config = {
      height = 0.50,
    },
    mappings = {
      i = mappings,
      n = mappings,
    },
    borderchars = M.border,
  },
})

local SEARCH_DEFAULTS = {
  previewer = false,
  shorten_path = true,
  layout_strategy = 'horizontal',
}

function M.find_files()
  require('telescope.builtin').find_files(vim.tbl_extend('force', SEARCH_DEFAULTS, {
    hidden = true,
    cwd = vim.fn.getcwd(),
  }))
end

function M.live_grep()
  require('telescope.builtin').live_grep(vim.tbl_extend('force', SEARCH_DEFAULTS, {
    cwd = vim.fn.getcwd(),
  }))
end

function M.lsp_references()
  require('telescope.builtin').lsp_references({ show_line = false })
end

function M.lsp_definitions()
  require('telescope.builtin').lsp_definitions({ show_line = false })
end

function M.lsp_implementations()
  require('telescope.builtin').lsp_implementations({ show_line = false })
end

function M.lsp_document_symbols()
  require('telescope.builtin').lsp_document_symbols({ show_line = false })
end

function M.open_nvim()
  require('telescope.builtin').find_files({
    cwd = '~/.mark/config/nvim',
  })
end

function M.livegrep_nvim()
  require('telescope.builtin').live_grep(vim.tbl_extend('force', SEARCH_DEFAULTS, {
    cwd = '~/.mark/config/nvim',
  }))
end

function M.livegrep_current_file(args)
  local file = vim.api.nvim_buf_get_name(0)
  local dir = vim.fn.fnamemodify(file, ':h')
  require('telescope.builtin').live_grep(vim.tbl_extend('force', SEARCH_DEFAULTS, {
    cwd = dir,
  }))
end

function M.livegrep_with_file_ext(args)
  local current_buf_ext = vim.fn.expand('%:e')
  local ext = vim.fn.input('Live grep with file extension: ', current_buf_ext)
  require('telescope.builtin').live_grep(vim.tbl_extend('force', SEARCH_DEFAULTS, {
    glob_pattern = '*.' .. ext,
  }))
end

vim.keymap.set('n', '<c-p>', M.find_files)
vim.keymap.set('n', '<c-o>', M.live_grep)
vim.keymap.set('n', '<c-u>', M.livegrep_with_file_ext)
vim.keymap.set('n', '<c-l>', M.livegrep_current_file)
vim.keymap.set('n', '<c-n>', M.open_nvim)
vim.keymap.set('n', '<c-no>', M.livegrep_nvim)

-- Second, separate setup() call: telescope.setup() merges into the existing
-- config, so this only adds the fzf-native extension's own options.
-- NOTE: `load_extension('fzf')` is never called, so this extension config is
-- currently inactive.
require('telescope').setup({
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = 'smart_case',
    },
  },
})

return M
