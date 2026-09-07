-- Unused: not required anywhere, and superseded by lua/custom/menu/menu.lua
-- (the version actually wired up via lua/config/nvim.lua). The original also
-- had a syntax error below (`"KEY" = value` isn't valid Lua table syntax for
-- a bare string key; needs `["KEY"] = value`), fixed here to match its
-- siblings, but this file still isn't loaded by anything.
local U = require 'config.utils'

vim.g.menu_commands = {
  {
    ['text'] = 'Run Mobile',
    ['cmd'] = 'npm run serve',
  },
  {
    ['text'] = 'Run API Server',
    ['cmd'] = 'dotnet build && dotnet run bin/Debug/netcoreapp3.1/CyberMetrics.FaciliWorks.Web.API.dll',
    ['cwd'] = '../../CyberMetrics.FaciliWorks.NetCore.API',
  },
  {
    ['text'] = 'Run IIS Server',
    ['cmd'] = 'dotnet build && dotnet run bin/Debug/netcoreapp3.1/CyberMetrics.FaciliWorks.Web.IdentityServer.dll',
    ['cwd'] = '../../CyberMetrics.FaciliWorks.NetCore.IdentityServer',
  },
  {
    ['text'] = 'Run API Server(Mobile)',
    ['cmd'] = 'dotnet build && dotnet run bin/Debug/netcoreapp3.1/CyberMetrics.FaciliWorks.Web.API.dll',
    ['cwd'] = '../CyberMetrics.FaciliWorks.NetCore.API',
    ['env'] = {
      ['ASPNETCORE_ENVIRONMENT'] = 'Development',
    },
  },
  {
    ['text'] = 'Run IIS Server(Mobile)',
    ['cmd'] = 'dotnet build && dotnet run bin/Debug/netcoreapp3.1/CyberMetrics.FaciliWorks.Web.IdentityServer.dll',
    ['cwd'] = '../CyberMetrics.FaciliWorks.NetCore.IdentityServer',
    ['env'] = {
      ['ASPNETCORE_ENVIRONMENT'] = 'Development',
    },
  },
  {
    ['text'] = 'Serve Site',
    ['cmd'] = 'npm run serve-site',
  },
  {
    ['text'] = 'Serve Admin',
    ['cmd'] = 'npm run serve-admin',
  },
  {
    ['text'] = 'Serve Org Admin',
    ['cmd'] = 'npm run serve-orgadmin',
  },
  {
    ['text'] = 'Run Site',
    ['cmd'] = 'npm run serve',
  },
  {
    ['text'] = 'Open Terminal',
    ['cmd'] = 'urxvt &',
  },
  {
    ['text'] = 'Ng Serve',
    ['cmd'] = 'ng serve',
  },
}

vim.g.use_internal_term = 1

U.map('n', '<leader>fw', ':call menu#open()<cr>')

vim.cmd('autocmd VimResized * :call menu#repaint()<cr>')
