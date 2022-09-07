local g = vim.g

-- Open NvimTree on Vim open.
-- vim.cmd [[autocmd VimEnter * NvimTreeOpen]]
--

require "nvim-tree".setup {
  actions = {
    open_file = {
      quit_on_open = false,
      resize_window = false,
      window_picker = {
        enable = true,
        chars = "1234567890",
        exclude = {
          filetype = {"notify", "packer", "qf"},
          buftype = {"terminal"}
        }
      }
    }
  },
  filters = {
    dotfiles = false,
    custom = {".git", "node_modules"},
    exclude = {}
  },
  -- updates the root directory of the tree on `DirChanged` (when your run `:cd` usually)
  update_cwd = false,
  -- update the focused file on `BufEnter`, un-collapses the folders recursively until it finds the file
  update_focused_file = {
    -- enables the feature
    enable = true,
    -- update the root directory of the tree to the one of the folder containing the file if the file is not under the current root directory
    -- only relevant when `update_focused_file.enable` is true
    update_cwd = true,
    -- list of buffer names / filetypes that will not update the cwd if the file isn't found under the current root directory
    -- only relevant when `update_focused_file.update_cwd` is true and `update_focused_file.enable` is true
    ignore_list = {}
  },
  -- configuration options for the system open command (`s` in the tree by default)
  system_open = {
    -- the command to run this, leaving nil should work in most cases
    cmd = nil,
    -- the command arguments as a list
    args = {}
  },
  git = {
    enable = true,
    ignore = false,
    timeout = 300
  },
  view = {
    -- width of the window, can be either a number (columns) or a string in `%`
    width = 30,
    height = 30,
    -- side of the tree, can be one of 'left' | 'right' | 'top' | 'bottom'
    side = "left",
    hide_root_folder = false,
    preserve_window_proportions = false,
    number = false,
    relativenumber = false,
    signcolumn = "yes",
    mappings = {
      -- custom only false will merge the list with the default mappings
      -- if true, it will only use your list to set the mappings
      custom_only = false,
      -- list of mappings to set on the tree manually
      list = {}
    }
  }
}
