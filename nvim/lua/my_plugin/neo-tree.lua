-- neo-tree.nvim setup, toggled with <C-i> (see lua/config/mapping.lua).
local U = require 'config.utils'
local input = require 'custom.menu.input'

-- Directory to run a command in for the given tree node: the file's parent
-- for a file node, or the node's own path for a directory node.
local function get_dir_by_node(node)
  if node.type == 'file' then
    return node._parent_id
  end
  return node.path
end

-- Runs `command` in `cwd` as a background job, refreshing the tree on exit.
-- Used by the <leader>s "run command here" mapping below.
local function startjob(command, cwd, state)
  vim.fn.jobstart({ 'bash', '-c', command }, {
    cwd = cwd,
    detach = true,
    on_stderr = function(_, data)
      if data == nil or data == '' then
        print('Command error')
      end
    end,
    on_exit = function()
      state.commands.refresh(state)
    end,
  })
end

require('neo-tree').setup({
  enable_diagnostics = false,
  enable_git_status = false,
  popup_border_style = U.border,
  filesystem = {
    window = {
      columns = { 'icon', 'name' },
      mappings = {
        ['<leader>s'] = {
          function(state)
            local node = state.tree:get_node()
            local callback = function(command)
              if command == nil or command == '' then return end
              startjob(command, get_dir_by_node(node), state)
            end
            input.show({
              title = ' Execute Command ',
              default_value = '',
              callback = callback,
            })
          end,
        },
      },
      popup = {
        size = { width = '80%' },
        position = '50%',
      },
    },
    filtered_items = {
      hide_dotfiles = false,
    },
  },
  default_component_configs = {
    window = {
      columns = { 'icon', 'name' },
      width = 60,
    },
    indent = {
      with_markers = true,
    },
    icon = {
      folder_closed = "",
      folder_open = "",
      folder_empty = "",
      default = "",
    },
  },
})

vim.cmd('hi NeoTreeTitleBar guibg=#3d59a1 guifg=#c0caf5')
