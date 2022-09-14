-- https://github.com/wbthomason/dotfiles/blob/387ded8ad4c3cb9d5000edbd3b18bc8cb8a186e9/neovim/.config/nvim/lua/config/utils.lua
local cmd = vim.cmd
local o, wo, bo = vim.o, vim.wo, vim.bo
local map_key = vim.api.nvim_set_keymap
local g = vim.g

local function opt(op, v, scopes)
    scopes = scopes or {o}
    for _, s in ipairs(scopes) do
        s[op] = v
    end
end

local function autocmd(group, cmds, clear)
    clear = clear == nil and false or clear
    if type(cmds) == "string" then
        cmds = {cmds}
    end
    cmd("augroup " .. group)
    if clear then
        cmd [[au!]]
    end
    for _, c in ipairs(cmds) do
        cmd("autocmd " .. c)
    end
    cmd [[augroup END]]
end

local function map(modes, lhs, rhs, opts)
    opts = opts or {}
    opts.noremap = opts.noremap == nil and true or opts.noremap
    if type(modes) == "string" then
        modes = {modes}
    end
    for _, mode in ipairs(modes) do
        map_key(mode, lhs, rhs, opts)
    end
end

g.t_Co = 256
g.base16colorspace = 256

cmd("filetype plugin indent on")

autocmd(
    "misc_aucmds",
    {
        [[FileType yaml setlocal ts=2 sts=2 sw=2 expandtab]],
        [[FileType yaml setl indentkeys-=<:>]]
    },
    true
)

g.loaded_python_provider = 0
g.python_host_prog = "/usr/bin/python2"
g.python3_host_prog = "/usr/bin/python"
g.netrw_browsex_viewer = "xdg-open"

local buffer = {o, bo}
local window = {o, wo}

opt("title", false)
opt("clipboard", "unnamedplus")
opt("swapfile", false, buffer)
opt("wrap", false, window)
opt("number", true, window)
opt("linebreak", true, window)
opt("showbreak", "━━")
opt("breakindent", true, window)
opt("tabstop", 2, buffer)
opt("shiftwidth", 2)
opt("expandtab", true, buffer)
opt("shiftround", true)
opt("lazyredraw", true)
opt("colorcolumn", "80", window)
opt("hidden", true)
opt("list", true)
opt("termguicolors", true)
opt("syntax", "enable")
opt("hlsearch", false)
opt("splitbelow", true)
opt("splitright", true)
opt("showmode", false)
opt("foldminlines", 5)
opt("foldmethod", "indent")

local map = vim.api.nvim_set_keymap
local opts = {noremap = true}

-- {{ General
vim.g.maplocalleader = ","
vim.g.mapleader = ","

-- Paste more than once.
map("x", "p", "pgvy", opts)

-- Clear search highlights.
map("n", "<Leader>cs", ":nohls<CR>", opts)

-- Tab movement.
map("n", "<c-Left>", "<cmd>tabpre<cr>", opts)
map("n", "<c-Right>", "<cmd>tabnext<cr>", opts)

-- }}

-- Telescope
map("n", "<leader>f", ":Telescope live_grep<CR>", opts)
map("n", "<C-p>", ':lua require("telescope.builtin").git_files()<CR>', opts)
map("n", "<leader>gs", ":Telescope git_files<CR>", opts)

-- Completion
map("i", "<tab>", "<Plug>(completion_smart_tab)", opts)
map("i", "<s-tab>", "<Plug>(completion_smart_s_tab)", opts)

-- ALE
map("n", "<silent> <C-k>", "<Plug>(ale_previous)", opts)
map("n", "<silent> <C-j>", "<Plug>(ale_next)", opts)
map("n", "<leader>rn", ":ALERename<CR>", opts)
map("n", "<leader>ss", ":ALESymbolSearch", opts)

-- Nvim-Tree
map("n", "<C-n>", ':lua require("nvim-tree").toggle()<CR>', opts)

-- DAP
map("n", "<leader>bp", ':lua require("dap").toggle_breakpoint()<CR>', opts)
map("n", "<leader>dap", ':lua require("dap").continue()<CR>', opts)
map("n", "<leader>dui", ':lua require("dapui").toggle()<CR>', opts)

-- Go
local go_keybindings = function()
    map("n", "<leader>gg", "<Plug>(go-doc)", opts)
    map("n", "<leader>gv", "<Plug>(go-doc-vertical)", opts)
    map("n", "<leader>gdb", "<Plug>(go-doc-browser)", opts)
    map("n", "<leader>gta", "<Plug>(go-alternate-split)", opts)
    map("n", "<leader>gtt", "<Plug>(go-test)", opts)
    map("n", "<leader>gtf", ":GoTestFunc!<cr>", opts)
    map("n", "<leader>gtc", "<Plug>(go-coverage-toggle)", opts)
    map("n", "<leader>gcb", "<Plug>(go-cover-browser)", opts)
    map("n", "<leader>dc", ":DlvConnect vim.env.DLV_SERVER_HOST<CR>", opts)
    map("n", "<leader>ca", ":DlvClearAll <CR>", opts)
    map("n", "<leader>dt", ":DlvToggleBreakpoint <CR>", opts)
end

-- LSP
-- https://github.com/neovim/nvim-lspconfig/blob/da7461b596d70fa47b50bf3a7acfaef94c47727d/doc/lspconfig.txt#L444
-- https://neovim.discourse.group/t/jump-to-definition-in-vertical-horizontal-split/2605/14
map("n", "<leader>gd", ':lua require"telescope.builtin".lsp_definitions({jump_type="vsplit"})<CR>', opts)
