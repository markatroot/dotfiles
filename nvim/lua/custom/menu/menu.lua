-- Sets up g:menu_commands, the command list rendered by the floating-window
-- runner in autoload/menu.vim (the actual active consumer). The `M` table
-- below (a nui.menu-based popup) is a separate, currently-unused alternative
-- UI for the same command list — nothing calls M.show today.
local Menu = require 'nui.menu'

local DOTNET_API_CMD = 'dotnet build && dotnet run bin/Debug/net6.0/CyberMetrics.FaciliWorks.Web.API.dll'
local DOTNET_IDENTITY_CMD = 'dotnet build && dotnet run bin/Debug/net6.0/CyberMetrics.FaciliWorks.Web.IdentityServer.dll'
local ASPNET_DEV_ENV = { ASPNETCORE_ENVIRONMENT = 'Development' }

vim.g.menu_commands = {
  {
    text = 'Run Mobile',
    cmd = 'npm run serve',
  },
  {
    text = 'Run API Server',
    cmd = DOTNET_API_CMD,
    cwd = '../../CyberMetrics.FaciliWorks.NetCore.API',
    env = ASPNET_DEV_ENV,
  },
  {
    text = 'Run IIS Server',
    cmd = DOTNET_IDENTITY_CMD,
    cwd = '../../CyberMetrics.FaciliWorks.NetCore.IdentityServer',
    env = ASPNET_DEV_ENV,
  },
  {
    text = 'Run API Server(Mobile)',
    cmd = DOTNET_API_CMD,
    cwd = '../CyberMetrics.FaciliWorks.NetCore.API',
    env = ASPNET_DEV_ENV,
  },
  {
    text = 'Run IIS Server(Mobile)',
    cmd = DOTNET_IDENTITY_CMD,
    cwd = '../CyberMetrics.FaciliWorks.NetCore.IdentityServer',
    env = ASPNET_DEV_ENV,
  },
  {
    text = 'Serve Site',
    cmd = 'npm run serve-site',
  },
  {
    text = 'Serve Admin',
    cmd = 'npm run serve-admin',
  },
  {
    text = 'Serve Org Admin',
    cmd = 'npm run serve-orgadmin',
  },
  {
    text = 'Run Site',
    cmd = 'npm run serve',
  },
  {
    text = 'Open Terminal',
    cmd = 'urxvt &',
  },
  {
    text = 'Ng Serve',
    cmd = 'ng serve',
  },
}

local M = {}

M.on_submit = function(menu) end

M.icons = {
  not_running = '',
  running = '',
}

M.running_commands = {}
M.command_lines = {}

M.popup_options = {
  position = '50%',
  size = {
    width = 35,
    height = 6,
  },
  border = {
    style = { '﵇', 'ﵓ', '﵈', 'ﵔ', 'ﵐ', 'ﵑ', '﵉', 'ﵒ' },
    text = {
      top = ' Select command to Execute ',
      top_align = 'center',
    },
  },
  win_options = {
    winhighlight = 'Normal:Normal,FloatBorder:Normal',
  },
}

M.options = {
  lines = M.command_lines,
  max_width = 70,
  size = {
    width = 50,
    height = 40,
  },
  keymap = {
    focus_next = { 'j', '<Down>', '<Tab>' },
    focus_prev = { 'k', '<Up>', '<S-Tab>' },
    close = { '<Esc>', '<C-c>' },
    submit = { '<CR>', '<Space>' },
  },
  on_close = function()
    print('Menu Closed!')
  end,
  on_submit = function(item)
    print('Menu Submitted: ', item.text)
  end,
}

local function menu_commands_to_lines()
  for _, value in pairs(vim.g.menu_commands) do
    local icon = M.running_commands[value.text] ~= nil and M.icons.running or M.icons.not_running
    table.insert(M.command_lines, Menu.item(icon .. ' ' .. value.text, value))
  end
end

function M.show()
  M.command_lines = {}
  menu_commands_to_lines()
  M.options.lines = M.command_lines
  local menu = Menu(M.popup_options, M.options)
  local bufnr = menu.bufnr
  vim.keymap.set('n', 't', function()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local item = M.options.lines[cursor[1]]
  end, { buffer = bufnr })
  menu:mount()
end

return M
