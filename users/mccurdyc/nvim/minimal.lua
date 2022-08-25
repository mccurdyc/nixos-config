local cmd = vim.cmd
local o, wo, bo = vim.o, vim.wo, vim.bo

local function opt(o, v, scopes)
  scopes = scopes or {o_s}
  for _, s in ipairs(scopes) do
    s[o] = v
  end
end

local buffer = {o, bo}
local window = {o, wo}

cmd("filetype plugin indent on")

opt("clipboard", "unnamedplus")
opt("swapfile", false, buffer)
opt("title", true)
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
opt("termguicolors", true)
opt("colorcolumn", "80", window)
opt("hidden", true)
opt("list", true)
opt("syntax", "enable")
opt("hlsearch", false)
opt("splitbelow", true)
opt("splitright", true)
opt("showmode", false)
opt("foldminlines", 5)
opt("foldmethod", "indent")

require("lualine").setup()
