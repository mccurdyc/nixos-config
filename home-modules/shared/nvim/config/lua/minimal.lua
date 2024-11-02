local cmd = vim.cmd
local o, wo, bo = vim.o, vim.wo, vim.bo

local function opt(o, v, scopes)
	scopes = scopes or { o_s }
	for _, s in ipairs(scopes) do
		s[o] = v
	end
end

local buffer = { o, bo }
local window = { o, wo }

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
opt("foldminlines", 1)
opt("foldmethod", "indent")

-- $HOME/.local/share/nvim/lazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    -- bootstrap lazy.nvim
    -- stylua: ignore
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath
    })
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

require("lazy").setup({
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("telescope").setup()
		end,
	},
})

vim.api.nvim_create_autocmd('FileType', {
  -- This handler will fire when the buffer's 'filetype' is "python"
  pattern = 'lua',
  callback = function(args)
    vim.lsp.start({
      name = 'lua_ls',
      cmd = {'lua-language-server'},
      root_dir = vim.fs.root(args.buf, {'.git'}),
    })
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  -- This handler will fire when the buffer's 'filetype' is "python"
  pattern = 'go',
  callback = function(args)
    vim.lsp.start({
      name = 'gopls',
      cmd = {'gopls'},
      root_dir = vim.fs.root(args.buf, {'go.mod'}),
    })
  end,
})
