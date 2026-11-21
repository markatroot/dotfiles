-- Telescope setup + custom pickers, bound to <C-p>/<C-o>/etc below.
-- Telescope itself is only required on the first picker call (see
-- builtin()), so it costs nothing at startup.
local M = {}

local mappings = {
  ['<C-p>'] = 'close',
  ['<C-k>'] = 'move_selection_previous',
  ['<C-j>'] = 'move_selection_next',
}

local did_setup = false

local function builtin()
  if not did_setup then
    did_setup = true
    local telescope = require('telescope')
    telescope.setup({
      defaults = {
        file_ignore_patterns = { 'node_modules', '@girs' },
        layout_config = {
          height = 0.50,
        },
        mappings = {
          i = mappings,
          n = mappings,
        },
      },
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = 'smart_case',
        },
      },
    })
    -- Native sorter; requires build/libfzf.so (built by the PackChanged
    -- hook in init.lua). Falls back to the Lua sorter if missing.
    pcall(telescope.load_extension, 'fzf')
  end
  return require('telescope.builtin')
end

local SEARCH_DEFAULTS = {
  previewer = false,
  shorten_path = true,
  layout_strategy = 'horizontal',
}

function M.find_files()
  builtin().find_files(vim.tbl_extend('force', SEARCH_DEFAULTS, {
    hidden = true,
    cwd = vim.fn.getcwd(),
  }))
end

function M.live_grep()
  builtin().live_grep(vim.tbl_extend('force', SEARCH_DEFAULTS, {
    cwd = vim.fn.getcwd(),
  }))
end

function M.lsp_references()
  builtin().lsp_references({ show_line = false })
end

function M.lsp_definitions()
  builtin().lsp_definitions({ show_line = false })
end

function M.lsp_implementations()
  builtin().lsp_implementations({ show_line = false })
end

function M.lsp_document_symbols()
  builtin().lsp_document_symbols({ show_line = false })
end

function M.open_nvim()
  builtin().find_files({
    cwd = '~/env/config/nvim',
  })
end

function M.livegrep_nvim()
  builtin().live_grep(vim.tbl_extend('force', SEARCH_DEFAULTS, {
    cwd = '~/env/config/nvim',
  }))
end

function M.livegrep_current_file(args)
  local file = vim.api.nvim_buf_get_name(0)
  local dir = vim.fn.fnamemodify(file, ':h')
  builtin().live_grep(vim.tbl_extend('force', SEARCH_DEFAULTS, {
    cwd = dir,
  }))
end

function M.livegrep_with_file_ext(args)
  local current_buf_ext = vim.fn.expand('%:e')
  local ext = vim.fn.input('Live grep with file extension: ', current_buf_ext)
  builtin().live_grep(vim.tbl_extend('force', SEARCH_DEFAULTS, {
    glob_pattern = '*.' .. ext,
  }))
end

vim.keymap.set('n', '<c-p>', M.find_files)
vim.keymap.set('n', '<c-o>', M.live_grep)
vim.keymap.set('n', '<c-u>', M.livegrep_with_file_ext)
vim.keymap.set('n', '<c-l>', M.livegrep_current_file)
vim.keymap.set('n', '<c-n>', M.open_nvim)
vim.keymap.set('n', '<c-no>', M.livegrep_nvim)

return M
