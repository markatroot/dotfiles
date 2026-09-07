-- DAP adapter definitions and per-language debug configurations (node2 via
-- vscode-node-debug2, coreclr/netcoredbg for C#).
local dap = require 'dap'

local M = {}

function M.configure()
  dap.adapters.node2 = {
    type = 'executable',
    command = 'node',
    args = { os.getenv('HOME') .. '/Documents/Compiled/vscode-node-debug2/out/src/nodeDebug.js' },
  }

  dap.adapters.coreclr = {
    type = 'executable',
    command = '/home/mark/.mark/lsp/netcoredbg/netcoredbg',
    args = { '--interpreter=vscode' },
  }

  dap.configurations.javascript = {
    {
      name = 'Launch',
      type = 'node2',
      request = 'launch',
      program = '${file}',
      cwd = vim.fn.getcwd(),
      sourceMaps = true,
      protocol = 'inspector',
      console = 'integratedTerminal',
    },
    {
      -- Requires the node process to already be started with the `--inspect` flag.
      name = 'Attach to process',
      type = 'node2',
      request = 'attach',
      processId = require('dap.utils').pick_process,
    },
  }

  dap.configurations.cs = {
    {
      type = 'netcoredbg',
      name = 'launch - netcoredbg',
      request = 'launch',
      program = function()
        return vim.fn.input('Path to dll', vim.fn.getcwd() .. '/bin/Debug/', 'file')
      end,
    },
    {
      type = 'coreclr',
      name = 'launch - IS',
      request = 'launch',
      program = function()
        return vim.fn.getcwd() .. '/bin/Debug/net9.0/CyberMetrics.FaciliWorks.Web.IdentityServer.dll'
      end,
    },
    {
      type = 'coreclr',
      name = 'launch - API',
      request = 'launch',
      program = function()
        return vim.fn.getcwd() .. '/bin/Debug/net9.0/CyberMetrics.FaciliWorks.Web.API.dll'
      end,
    },
    {
      type = 'netcoredbg',
      name = 'launch - IS (from root)',
      request = 'launch',
      cwd = vim.fn.getcwd() .. '/src/Web/CyberMetrics.FaciliWorks.NetCore.IdentityServer/',
      program = function()
        return 'bin/Debug/net9.0/CyberMetrics.FaciliWorks.Web.IdentityServer.dll'
      end,
    },
    {
      type = 'netcoredbg',
      name = 'launch - API (from root)',
      request = 'launch',
      cwd = vim.fn.getcwd() .. '/src/Web/CyberMetrics.FaciliWorks.NetCore.API',
      program = function()
        return 'bin/Debug/net9.0/CyberMetrics.FaciliWorks.Web.API.dll'
      end,
    },
  }
end

return M
