-- Floating cmdline built on nui.nvim
-- Place at: ~/.config/nvim/lua/config/cmdline.lua
-- Load with: require("config.cmdline")

local Input = require("nui.input")
local event = require("nui.utils.autocmd").event

local M = {}

local prompt = ":"

function M.open(default)
  local input = Input({
    relative = "editor",
    position = { row = "40%", col = "50%" },
    size = { width = 60, height = 1 },
    zindex = 60,
    border = {
      style = "rounded",
      padding = { top = 0, bottom = 0, left = 0, right = 0 },
      text = { top = " Cmdline ", top_align = "center" },
    },
    win_options = {
      winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
    },
    buf_options = {
      buflisted = false,
      filetype = "vim",
      syntax = "vim",
    },
  }, {
    prompt = prompt,
    default_value = default or "",
    on_submit = function(value)
      if value == "" then return end
      vim.fn.histadd("cmd", value)
      local ok, err = pcall(vim.cmd, value)
      if not ok then vim.notify(err, vim.log.levels.ERROR) end
    end,
  })

  input:mount()

  vim.bo[input.bufnr].buflisted = false
  vim.bo[input.bufnr].filetype = "vim"
  vim.bo[input.bufnr].syntax = "vim"

  -- close on Esc or when focus leaves
  input:map("i", "<Esc>", function() input:unmount() end, { noremap = true })
  input:on(event.BufLeave, function() input:unmount() end)

  -- Tab: open completion menu, or cycle if it's already open
  input:map("i", "<Tab>", function()
    if vim.fn.pumvisible() == 1 then
      vim.api.nvim_feedkeys(vim.keycode("<C-n>"), "n", false)
      return
    end
    local line = vim.api.nvim_get_current_line():sub(#prompt + 1)
    local items = vim.fn.getcompletion(line, "cmdline")
    local start = line:find("%S*$")
    vim.fn.complete(#prompt + start, items)
  end, { noremap = true })

  -- Shift-Tab: cycle backwards through completions
  input:map("i", "<S-Tab>", function()
    if vim.fn.pumvisible() == 1 then
      vim.api.nvim_feedkeys(vim.keycode("<C-p>"), "n", false)
    end
  end, { noremap = true })
end

-- Override : in normal mode (respects counts, e.g. 5: -> .,.+4)
vim.keymap.set("n", ":", function()
  local count = vim.v.count
  M.open(count > 0 and (".,.+" .. (count - 1)) or nil)
end, { desc = "Floating cmdline" })

-- Override : in visual mode (pre-fills '<,'>)
vim.keymap.set("x", ":", function()
  -- leave visual mode first so the '< and '> marks get set
  vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "nx", false)
  M.open("'<,'>")
end, { desc = "Floating cmdline (range)" })

-- Escape hatch to the real cmdline (e.g. for :s with live preview)
vim.keymap.set({ "n", "x" }, "<leader>;", ":", { desc = "Native cmdline" })

return M
