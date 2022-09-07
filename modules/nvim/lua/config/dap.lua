-- https://github.com/go-delve/delve/blob/master/Documentation/usage/dlv_dap.md
-- https://github.com/leoluz/nvim-dap-go
local dap = require("dap")
require("dapui").setup(
  {
    icons = {expanded = "▾", collapsed = "▸"},
    mappings = {
      -- Use a table to apply multiple mappings
      expand = {"<CR>"},
      open = "o",
      remove = "d",
      edit = "e",
      repl = "r",
      toggle = "t"
    },
    expand_lines = false,
    -- Layouts define sections of the screen to place windows.
    -- The position can be "left", "right", "top" or "bottom".
    -- The size specifies the height/width depending on position. It can be an Int
    -- or a Float. Integer specifies height/width directly (i.e. 20 lines/columns) while
    -- Float value specifies percentage (i.e. 0.3 - 30% of available lines/columns)
    -- Elements are the elements shown in the layout (in order).
    -- Layouts are opened in order so that earlier layouts take priority in window sizing.
    layouts = {
      {
        elements = {
          -- Elements can be strings or table with id and size keys.
          {id = "scopes", size = 0.8},
          "breakpoints",
          "stacks",
          "repl"
        },
        size = 50,
        position = "left"
      },
      {
        elements = {
          "console"
        },
        size = 0.25, -- 25% of total lines
        position = "bottom"
      }
    },
    floating = {
      max_height = 0.8, -- These can be integers or a float between 0 and 1.
      max_width = 0.8, -- Floats will be treated as percentage of your screen.
      border = "single", -- Border style. Can be "single", "double" or "rounded"
      mappings = {
        close = {"q", "<Esc>"}
      }
    },
    windows = {indent = 1},
    render = {
      max_type_length = nil -- Can be integer or nil.
    }
  }
)

vim.fn.sign_define("DapBreakpoint", {text = "", texthl = "", linehl = "", numhl = ""})

dap.adapters.go = {
  type = "server",
  port = "${port}",
  executable = {
    command = "dlv",
    args = {"dap", "-l", "127.0.0.1:${port}"}
  }
}

-- https://github.com/go-delve/delve/blob/master/Documentation/usage/dlv_dap.md
-- https://github.com/leoluz/nvim-dap-go
dap.configurations.go = {
  {
    type = "go",
    name = "Debug",
    request = "launch",
    program = "${file}"
  },
  {
    type = "go",
    name = "Debug test", -- configuration for debugging test files
    request = "launch",
    mode = "test",
    program = "${file}"
  },
  -- works with go.mod packages and sub packages
  {
    type = "go",
    name = "Debug test (go.mod)",
    request = "launch",
    mode = "test",
    program = "./${relativeFileDirname}"
  }
}
