local actions = require("telescope.actions")
require("telescope").setup {
  defaults = {
    vimgrep_arguments = {
      "rg",
      "--hidden",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case"
    },
    mappings = {
      i = {
        ["<esc>"] = actions.close
      },
      n = {
        ["<esc>"] = actions.close,
        ["<cr>"] = false
      }
    },
    layout_config = {
      horizontal = {
        height = 0.8,
        width = 0.9
      }
    },
    prompt_prefix = "> ",
    selection_caret = "> ",
    entry_prefix = "  ",
    initial_mode = "insert",
    selection_strategy = "closest",
    sorting_strategy = "descending",
    layout_strategy = "horizontal",
    file_sorter = require "telescope.sorters".get_fuzzy_file,
    file_ignore_patterns = {},
    generic_sorter = require "telescope.sorters".get_generic_fuzzy_sorter,
    path_display = absolute,
    winblend = 0,
    border = {},
    borderchars = {"─", "│", "─", "│", "╭", "╮", "╯", "╰"},
    color_devicons = false,
    use_less = true,
    set_env = {["COLORTERM"] = "truecolor"}, -- default = nil,
    file_previewer = require "telescope.previewers".vim_buffer_cat.new,
    grep_previewer = require "telescope.previewers".vim_buffer_vimgrep.new,
    qflist_previewer = require "telescope.previewers".vim_buffer_qflist.new
  },
  pickers = {
    buffers = {
      sort_lastused = true
    },
    find_files = {
      hidden = true,
      --- no_ignore = true,
      previewer = false,
      layout_config = {prompt_position = "top"}
    }
  },
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case"
    }
  }
}

-- load extensions after calling setup function
require("telescope").load_extension("fzf")
require("telescope").load_extension("dap")
