-- Override deprecate to filter sign_define warnings
-- Temporarily disable deprecate for sign definitions because vim.diagnostic.config doesn't
-- yet support this. It claims to and there are approaches, but it doesn't properly
-- highlight the linenumber instead of the sign column like I want.
vim.deprecate = function(name, alternative, version, plugin, backtrace)
	-- Ignore any deprecation warnings related to signs
	if name and (name:match("sign_define") or name:match("sign_")) then
		return
	end
end

-- https://github.com/wbthomason/dotfiles/blob/387ded8ad4c3cb9d5000edbd3b18bc8cb8a186e9/neovim/.config/nvim/lua/config/utils.lua
local cmd = vim.cmd
local o, wo, bo = vim.o, vim.wo, vim.bo
local map_key = vim.api.nvim_set_keymap
local g = vim.g

local function opt(op, v, scopes)
	scopes = scopes or { o }
	for _, s in ipairs(scopes) do
		s[op] = v
	end
end

local function autocmd(group, cmds, clear)
	clear = clear == nil and false or clear
	if type(cmds) == "string" then
		cmds = { cmds }
	end
	cmd("augroup " .. group)
	if clear then
		cmd([[au!]])
	end
	for _, c in ipairs(cmds) do
		cmd("autocmd " .. c)
	end
	cmd([[augroup END]])
end

local function map(modes, lhs, rhs, opts)
	opts = opts or {}
	opts.noremap = opts.noremap == nil and true or opts.noremap
	if type(modes) == "string" then
		modes = { modes }
	end
	for _, mode in ipairs(modes) do
		map_key(mode, lhs, rhs, opts)
	end
end

cmd("filetype plugin indent on")

-- nvim-tree recommendation
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1

g.loaded_python_provider = 0
g.python_host_prog = "/usr/bin/python2"
g.python3_host_prog = "/usr/bin/python"
-- just have :GBrowse echo the link
-- https://github.com/tpope/vim-fugitive/issues/1135#issuecomment-520175596
g.netrw_browsex_viewer = "dillo" -- GARBAGE hack; go look at git.nix

g.fzf_colors = {
	["fg"] = { "fg", "CursorLine" },
	["bg"] = { "bg", "Normal" },
	["hl"] = { "fg", "Comment" },
	["fg+"] = { "fg", "Special", "bold" },
	["bg+"] = { "bg", { "CursorLine", "Normal" } },
	["hl+"] = { "fg", "Statement" },
	["info"] = { "fg", "PreProc" },
	["prompt"] = { "fg", "Conditional" },
	["pointer"] = { "fg", "Exception" },
	["marker"] = { "fg", "Keyword" },
	["spinner"] = { "fg", "Label" },
	["header"] = { "fg", "Comment" },
	["gutter"] = "-1",
}

local buffer = { o, bo }
local window = { o, wo }

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
opt("list", false)
opt("syntax", "enable")
opt("hlsearch", false)
opt("splitbelow", true)
opt("signcolumn", "yes")
opt("splitright", true)
opt("showmode", false)
opt("foldminlines", 0) -- Minimum number of screen lines for a fold to be displayed closed.
opt("foldmethod", "indent")
opt("foldlevel", 0) -- Show top-level folds
opt("foldenable", true)
opt("cursorline", true)
opt("conceallevel", 1)
opt("modifiable", true)

cmd("filetype plugin indent on")

autocmd("misc_aucmds", {
	[[FileType yaml setlocal ts=2 sts=2 sw=2 expandtab]],
}, true)

autocmd("dont_fold_telescope_results", {
	[[FileType TelescopeResults setlocal foldexpr= foldmethod=manual]],
}, true)

autocmd("nix_foldlevel_1", {
	[[FileType nix setlocal foldlevel=1]],
}, true)

autocmd("conceallevel_0_to_avoid_red_quotes", {
	[[FileType json,md setlocal conceallevel=0]],
}, true)

local opts = { noremap = true }

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

function ReplaceWordUnderCursorWithWordFromPastebuffer(global_confirmation)
	local replace_context = global_confirmation and "gc" or "g"

	local word = vim.fn.expand("<cword>")
	local cmd = ":%s/\\<" .. word .. "\\>/\\=@0/" .. replace_context
	vim.cmd(cmd)
end

function ReplaceWordUnderCursorGlobally(global_confirmation)
	local replace_context = global_confirmation and "gc" or "g"
	local user_input = vim.fn.input("Enter replacement: ")

	local word = vim.fn.expand("<cword>")
	local cmd = ":%s/\\<" .. word .. "\\>/" .. user_input .. "/" .. replace_context
	vim.cmd(cmd)
end

-- Map the function to a key combination
map("n", "<Leader>rpc", ":lua ReplaceWordUnderCursorWithWordFromPastebuffer({global_confirmation=true})<CR>", opts)
map("n", "<Leader>rp", ":lua ReplaceWordUnderCursorWithWordFromPastebuffer()<CR>", opts)
map("n", "<Leader>rw", ":lua ReplaceWordUnderCursorGlobally()<CR>", opts)
map("n", "<Leader>rwc", ":lua ReplaceWordUnderCursorGlobally({global_confirmation=true})<CR>", opts)

-- "search term" ctrl-g "file extension"
map("n", "<leader>f", ":lua require('fzf-lua').live_grep({ cmd = 'rg --line-number' })<CR>", opts)
map("n", "<leader>b", ":lua require('fzf-lua').buffers()<CR>", opts)
map("n", "<C-p>", ":lua require('fzf-lua').files()<CR>", opts)
map(
	"n",
	"<C-g>",
	":lua require('fzf-lua').git_files({git_command={'git','diff','--name-only','origin/main'}})<CR>",
	opts
)

-- FzfLua when Telescope is slow

-- Telescope
-- map("n", "<leader>f", ":lua require('telescope.builtin').live_grep()<CR>", opts)
-- map("n", "<leader>b", ":lua require('telescope.builtin').buffers()<CR>", opts)
-- map("n", "<C-p>", ":lua require('telescope.builtin').find_files()<CR>", opts)
-- map(
-- 	"n",
-- 	"<C-g>",
-- 	":lua require('telescope.builtin').git_files({git_command={'git','diff','--name-only','origin/main'}})<CR>",
-- 	opts
-- )

-- LSP
-- https://github.com/neovim/nvim-lspconfig/blob/da7461b596d70fa47b50bf3a7acfaef94c47727d/doc/lspconfig.txt#L444
-- https://neovim.discourse.group/t/jump-to-definition-in-vertical-horizontal-split/2605/14
-- map("n", "<leader>gd", ':lua require"telescope.builtin".lsp_definitions({jump_type="vsplit"})<CR>', opts)

-- Source the colors configuration
local mccurdyc_colors = require("colors")

-- $HOME/.local/share/nvim/lazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"git@github.com:folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	"tpope/vim-fugitive",
	"tpope/vim-rhubarb", -- :GBrowse
	"tomtom/tcomment_vim",
	"nvim-lua/plenary.nvim",
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			local configs = require("nvim-treesitter.configs")

			configs.setup({
				auto_install = true,
				ensure_installed = {
					"go",
					"nix",
					"lua",
					"rust",
					"bash",
					"cue",
					"diff",
					"dockerfile",
					"gomod",
					"json",
					"make",
					"markdown",
					"terraform",
					"yaml",
					"query",
					"vim",
					"vimdoc",
				},
				sync_install = true,
				highlight = {
					enable = true,
					async = true,
					additional_vim_regex_highlighting = false,
					disable = { "json", "markdown" },
				},
				indent = { enable = true },
			})
		end,
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {},
		config = function()
			require("ibl").setup()
			require("ibl").overwrite({
				indent = { highlight = { "LineNr" }, char = "▎" },
				whitespace = {
					highlight = { "LineNr" },
					remove_blankline_trail = false,
				},
				scope = { enabled = false },
			})
		end,
	},
	{
		"ray-x/go.nvim",
		dependencies = { -- optional packages
			"ray-x/guihua.lua",
			"neovim/nvim-lspconfig",
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			require("go").setup({
				diagnostic = {
					underline = true,
					update_in_insert = false,
				},
			})
		end,
		ft = { "go", "gomod" },
	},
	{

		"nvim-tree/nvim-tree.lua",
		config = function()
			require("nvim-tree").setup({
				view = {
					signcolumn = "no",
					width = 20,
					float = {
						enable = false,
						quit_on_focus_loss = true,
						open_win_config = {
							relative = "editor",
							border = "rounded",
							width = 30,
							height = 30,
							row = 1,
							col = 1,
						},
					},
				},
				renderer = {
					icons = {
						web_devicons = {
							file = {
								enable = true,
								color = true,
							},
							folder = {
								enable = false,
								color = true,
							},
						},
						symlink_arrow = "l>>",
						show = {
							hidden = true,
						},
						glyphs = {
							default = "",
							symlink = "l>",
							bookmark = "",
							modified = "",
							hidden = "h>",
							folder = {
								arrow_closed = "<",
								arrow_open = ">",
								default = "",
								open = "",
								empty = "e>",
								empty_open = "",
								symlink = "",
								symlink_open = "",
							},
							git = {
								unstaged = "?",
								staged = "s>",
								unmerged = "um>",
								renamed = "r",
								untracked = "*",
								deleted = "d",
								ignored = "i",
							},
						},
					},
				},
				git = {
					enable = true,
					show_on_dirs = true,
					show_on_open_dirs = true,
					disable_for_dirs = {},
					timeout = 400,
					cygwin_support = false,
				},
				diagnostics = {
					icons = {
						hint = "h",
						info = "i",
						warning = "w",
						error = "e",
					},
				},
				filters = {
					enable = true,
					git_ignored = false,
					dotfiles = false,
				},
			})
		end,
	},
	{
		"L3MON4D3/LuaSnip",
		dependencies = { "honza/vim-snippets" },
		config = function()
			local luasnip = require("luasnip")
			require("luasnip.loaders.from_snipmate").lazy_load({
				paths = vim.fn.stdpath("data") .. "/lazy/vim-snippets/snippets",
			})
			-- Snippets
			-- https://github.com/tjdevries/config_manager/blob/master/xdg_config/nvim/after/plugin/luasnip.lua#L271-L285
			-- <c-j> is my expansion key
			-- this will expand the current item or jump to the next item within the snippet.
			vim.keymap.set({ "i", "s" }, "<c-j>", function()
				if luasnip.expand_or_jumpable() then
					luasnip.expand_or_jump()
				end
			end, { silent = true })

			-- <c-p> is my jump backwards key.
			-- this always moves to the previous item within the snippet
			vim.keymap.set({ "i", "s" }, "<c-p>", function()
				if luasnip.jumpable(-1) then
					luasnip.jump(-1)
				end
			end, { silent = true })
		end,
	},
	{
		"kevinhwang91/nvim-bqf",
		config = function()
			require("bqf").setup({
				auto_enable = true,
				auto_resize_height = true,
				preview = { auto_preview = false },
				func_map = { vsplit = "", ptogglemode = "z,", stoggleup = "" },
				filter = {
					fzf = {
						action_for = { ["ctrl-s"] = "split" },
						extra_opts = {
							"--bind",
							"ctrl-o:toggle-all",
							"--prompt",
							"> ",
						},
					},
				},
			})
		end,
	},
	{
		"rcarriga/nvim-dap-ui",
		dependencies = { "nvim-neotest/nvim-nio" },
		config = function()
			require("dapui").setup({
				icons = { expanded = "▾", collapsed = "▸" },
				mappings = {
					-- Use a table to apply multiple mappings
					expand = { "<CR>" },
					open = "o",
					remove = "d",
					edit = "e",
					repl = "r",
					toggle = "t",
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
							{ id = "scopes", size = 0.8 },
							"breakpoints",
							"stacks",
							"repl",
						},
						size = 50,
						position = "left",
					},
					{
						elements = { "console" },
						size = 0.25, -- 25% of total lines
						position = "bottom",
					},
				},
				floating = {
					max_height = 0.8, -- These can be integers or a float between 0 and 1.
					max_width = 0.8, -- Floats will be treated as percentage of your screen.
					border = "single", -- Border style. Can be "single", "double" or "rounded"
					mappings = { close = { "q", "<Esc>" } },
				},
				windows = { indent = 1 },
				render = {
					max_type_length = nil, -- Can be integer or nil.
				},
			})

			vim.keymap.set("n", "<leader>bp", require("dap").toggle_breakpoint)
			vim.keymap.set("n", "<leader>dc", require("dap").continue)
			vim.keymap.set("n", "<leader>dt", require("dapui").toggle)

			-- Set up the DAP UI to open automatically when debugging starts:
			local dap, dapui = require("dap"), require("dapui")
			dapui.setup()

			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
		end,
	},
	{ "mfussenegger/nvim-dap" },
	{
		"leoluz/nvim-dap-go",
		config = function()
			require("dap-go").setup({
				-- https://github.com/leoluz/nvim-dap-go#configuring
				dap_configurations = {
					{
						-- Must be "go" or it will be ignored by the plugin
						type = "go",
						name = "Attach remote",
						mode = "remote",
						request = "attach",
					},
				},
				-- delve configurations
				delve = {
					-- time to wait for delve to initialize the debug session.
					-- default to 20 seconds
					initialize_timeout_sec = 20,
					-- a string that defines the port to start delve debugger.
					-- default to string "${port}" which instructs nvim-dap
					-- to start the process in a random available port
					port = "${port}",
				},
			})
		end,
	},
	-- {
	-- 	"nvim-telescope/telescope.nvim",
	-- 	dependencies = { "nvim-lua/plenary.nvim" },
	-- 	config = function()
	-- 		require("telescope").setup({
	-- 			defaults = {
	-- 				-- :lua print(vim.inspect(require('telescope.config').values.file_ignore_patterns))
	-- 				file_ignore_patterns = {
	-- 					"vendor/.*",
	-- 					".git/.*",
	-- 					".direnv/.*",
	-- 				},
	-- 				mappings = {
	-- 					i = {
	-- 						-- Insert mode mappings
	-- 						["<C-d>"] = require("telescope.actions").results_scrolling_down,
	-- 						["<C-u>"] = require("telescope.actions").results_scrolling_up,
	-- 					},
	-- 					n = {
	-- 						-- Normal mode mappings
	-- 						["<C-d>"] = require("telescope.actions").results_scrolling_down,
	-- 						["<C-u>"] = require("telescope.actions").results_scrolling_up,
	-- 					},
	-- 				},
	-- 				vimgrep_arguments = {
	-- 					"rg",
	-- 					"--hidden",
	-- 					"--color=never",
	-- 					"--no-heading",
	-- 					"--with-filename",
	-- 					"--line-number",
	-- 					"--column",
	-- 					"--smart-case",
	-- 				},
	-- 				layout_config = { horizontal = { height = 0.8, width = 0.9 } },
	-- 				prompt_prefix = "> ",
	-- 				selection_caret = "> ",
	-- 				entry_prefix = "  ",
	-- 				initial_mode = "insert",
	-- 				selection_strategy = "closest",
	-- 				sorting_strategy = "descending",
	-- 				layout_strategy = "horizontal",
	-- 				file_sorter = require("telescope.sorters").get_fuzzy_file,
	-- 				generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
	-- 				path_display = "absolute",
	-- 				winblend = 0,
	-- 				border = {},
	-- 				borderchars = {
	-- 					"─",
	-- 					"│",
	-- 					"─",
	-- 					"│",
	-- 					"╭",
	-- 					"╮",
	-- 					"╯",
	-- 					"╰",
	-- 				},
	-- 				color_devicons = false,
	-- 				use_less = true,
	-- 				set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
	-- 			},
	-- 			pickers = {
	-- 				buffers = { sort_lastused = true },
	-- 				find_files = {
	-- 					hidden = true,
	-- 					--- no_ignore = true,
	-- 					previewer = false,
	-- 					layout_config = { prompt_position = "top" },
	-- 				},
	-- 			},
	-- 			--[[extensions = {
	-- 			fzf = {
	-- 			    fuzzy = true,
	-- 			    override_generic_sorter = true,
	-- 			    override_file_sorter = true,
	-- 			    case_mode = "smart_case"
	-- 			}
	-- 		    }]]
	-- 		})
	--
	-- 		-- load extensions after calling setup function
	-- 		-- require("telescope").load_extension("fzf")
	-- 	end,
	-- },
	{
		"folke/trouble.nvim",
		cmd = "Trouble",
		keys = {
			{
				"<leader>xx",
				"<cmd>Trouble diagnostics toggle<cr>",
				desc = "Diagnostics (Trouble)",
			},
			{
				"<leader>df",
				"<cmd>lua vim.diagnostic.open_float()<CR>",
				desc = "Diagnostics in Floating window",
			},
			{
				"<leader>xX",
				"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
				desc = "Buffer Diagnostics (Trouble)",
			},
			{
				"<leader>cs",
				"<cmd>Trouble symbols toggle focus=false<cr>",
				desc = "Symbols (Trouble)",
			},
			{
				"<leader>cl",
				"<cmd>Trouble lsp toggle focus=false win.position=bottom<cr>",
				desc = "LSP Definitions / references / ... (Trouble)",
			},
			{
				"<leader>xL",
				"<cmd>Trouble loclist toggle<cr>",
				desc = "Location List (Trouble)",
			},
			{
				"<leader>xQ",
				"<cmd>Trouble qflist toggle<cr>",
				desc = "Quickfix List (Trouble)",
			},
		},
		config = function()
			require("trouble").setup({
				auto_close = false, -- auto close when there are no items
				auto_open = false, -- auto open when there are items
				auto_preview = true, -- automatically open preview when on an item
				auto_refresh = true, -- auto refresh when open
				auto_jump = false, -- auto jump to the item when there's only one
				focus = false, -- Focus the window when opened
				restore = false, -- restores the last location in the list when opening
				follow = true, -- Follow the current item
				indent_guides = true, -- show indent guides
				max_items = 10, -- limit number of items that can be displayed per section
				multiline = true, -- render multi-line messages
				pinned = true, -- When pinned, the opened trouble window will be bound to the current buffer
				warn_no_results = false, -- show a warning when there are no results
				open_no_results = false, -- open the trouble window when there are no results
				-- fix color of quickfix/Trouble
				win = {
					-- https://github.com/folke/trouble.nvim/blob/42dcb58e95723f833135d5cf406c38bd54304389/lua/trouble/view/window.lua#L7
					size = {
						height = 5,
					},
				},
				keys = {
					["?"] = "help",
					r = "refresh",
					R = "toggle_refresh",
					q = "close",
					o = "jump_close",
					["<esc>"] = "cancel",
					["<cr>"] = "jump",
					["<2-leftmouse>"] = "jump",
					["<c-s>"] = "jump_split",
					["<c-v>"] = "jump_vsplit",
					-- go down to next item (accepts count)
					-- j = "next",
					["}"] = "next",
					["]]"] = "next",
					-- go up to prev item (accepts count)
					-- k = "prev",
					["{"] = "prev",
					["[["] = "prev",
					dd = "delete",
					d = { action = "delete", mode = "v" },
					i = "inspect",
					p = "preview",
					P = "toggle_preview",
					zo = "fold_open",
					zO = "fold_open_recursive",
					zc = "fold_close",
					zC = "fold_close_recursive",
					za = "fold_toggle",
					zA = "fold_toggle_recursive",
					zm = "fold_more",
					zM = "fold_close_all",
					zr = "fold_reduce",
					zR = "fold_open_all",
					zx = "fold_update",
					zX = "fold_update_all",
					zn = "fold_disable",
					zN = "fold_enable",
					zi = "fold_toggle_enable",
					gb = { -- example of a custom action that toggles the active view filter
						action = function(view)
							view:filter({ buf = 0 }, { toggle = true })
						end,
						desc = "Toggle Current Buffer Filter",
					},
				},
			})
		end,
	},
	{
		"nvimtools/none-ls.nvim",
		config = function()
			local null_ls = require("null-ls")

			local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
			null_ls.setup({
				-- format on save - https://github.com/jose-elias-alvarez/null-ls.nvim/wiki/Formatting-on-save#code
				on_attach = function(client, bufnr)
					vim.diagnostic.config({
						virtual_text = false,
						signs = true, -- it's this signs that's putting the 'W'
						underline = true,
						update_in_insert = false,
						severity_sort = true,
					})

					if client.supports_method("textDocument/formatting") then
						vim.api.nvim_clear_autocmds({
							group = augroup,
							buffer = bufnr,
						})
						vim.api.nvim_create_autocmd("BufWritePre", {
							group = augroup,
							buffer = bufnr,
							callback = function()
								-- https://github.com/jose-elias-alvarez/null-ls.nvim/wiki/Formatting-on-save#choosing-a-client-for-formatting
								vim.lsp.buf.format({
									bufnr = bufnr,
									filter = function(client)
										return client.name == "null-ls"
									end,
								})
							end,
						})
					end
				end,
				sources = {
					null_ls.builtins.code_actions.gitrebase,
					null_ls.builtins.code_actions.gitsigns,
					null_ls.builtins.code_actions.impl,
					null_ls.builtins.completion.spell,
					null_ls.builtins.diagnostics.deadnix,
					null_ls.builtins.diagnostics.opacheck,
					null_ls.builtins.diagnostics.regal,
					null_ls.builtins.diagnostics.cue_fmt.with({
						-- `cue vet` does not work on _tool.cue files
						runtime_condition = function(params)
							return not params.bufname:match("_tool%.cue$")
						end,
					}),
					null_ls.builtins.diagnostics.hadolint,
					-- null_ls.builtins.diagnostics.markdownlint,
					-- null_ls.builtins.diagnostics.shellcheck,
					null_ls.builtins.diagnostics.staticcheck,
					null_ls.builtins.diagnostics.statix,
					null_ls.builtins.diagnostics.trail_space,
					-- null_ls.builtins.diagnostics.todo_comments,
					null_ls.builtins.diagnostics.yamllint.with({
						extra_args = {
							"-d",
							"{extends: relaxed, rules: {line-length: {max: 120}, document-start: disable}}",
						},
					}), -- null_ls.builtins.formatting.beautysh,
					null_ls.builtins.formatting.cue_fmt,
					null_ls.builtins.formatting.cueimports,
					null_ls.builtins.formatting.just,
					null_ls.builtins.formatting.gofumpt,
					null_ls.builtins.formatting.goimports,
					null_ls.builtins.formatting.goimports_reviser,
					null_ls.builtins.formatting.stylua,
					null_ls.builtins.formatting.nixpkgs_fmt,
					null_ls.builtins.formatting.rego,
					null_ls.builtins.formatting.just,
					null_ls.builtins.formatting.shfmt.with({ extra_args = { "-i", "2", "-ci" } }),
					null_ls.builtins.formatting.terraform_fmt,
					null_ls.builtins.formatting.yamlfmt.with({
						-- https://github.com/google/yamlfmt/blob/main/docs/config-file.md#basic-formatter
						extra_args = { "-formatter", "indent=2,include_document_start=true,retain_line_breaks=true" },
					}),
				},
			})
		end,
	},
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup({
				signs = {
					add = { text = "│" },
					change = { text = "│" },
					delete = { text = "│" },
					topdelete = { text = "‾" },
					changedelete = { text = "~" },
				},
				on_attach = function(bufnr)
					local gs = package.loaded.gitsigns

					local function map(mode, l, r, opts)
						opts = opts or {}
						opts.buffer = bufnr
						vim.keymap.set(mode, l, r, opts)
					end

					-- Navigation
					map("n", "]c", function()
						if vim.wo.diff then
							return "]c"
						end
						vim.schedule(function()
							gs.next_hunk()
						end)
						return "<Ignore>"
					end, { expr = true })

					map("n", "[c", function()
						if vim.wo.diff then
							return "[c"
						end
						vim.schedule(function()
							gs.prev_hunk()
						end)
						return "<Ignore>"
					end, { expr = true })

					-- Actions
					map("n", "<leader>hs", gs.stage_hunk)
					map("n", "<leader>hr", gs.reset_hunk)
					map("v", "<leader>hs", function()
						gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
					end)
					map("v", "<leader>hr", function()
						gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
					end)
					map("n", "<leader>hS", gs.stage_buffer)
					map("n", "<leader>hu", gs.undo_stage_hunk)
					map("n", "<leader>hR", gs.reset_buffer)
					map("n", "<leader>hp", gs.preview_hunk)
					map("n", "<leader>hb", function()
						gs.blame_line({ full = true })
					end)
					map("n", "<leader>tb", gs.toggle_current_line_blame)
					map("n", "<leader>hd", gs.diffthis)
					map("n", "<leader>hD", function()
						gs.diffthis("~")
					end)
					map("n", "<leader>td", gs.toggle_deleted)

					-- Text object
					map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
				end,
			})
		end,
	},
	{
		"ibhagwan/fzf-lua",
		config = function()
			require("fzf-lua").setup({
				-- fzf-tmux resulted in a brief, but annoying, flicker after closing
				-- fzf_bin = "fzf-tmux",
				-- fzf_tmux_opts = { ["-d"] = "40%" },
				winopts = {
					split = "belowright new", -- open in a split instead?
				},
				files = {
					previewer = false,
				},
			})
		end,
	},
	{
		"NeogitOrg/neogit",
		dependencies = {
			"nvim-lua/plenary.nvim", -- required
			"sindrets/diffview.nvim", -- optional
			"ibhagwan/fzf-lua", -- optional
		},
		config = function()
			require("neogit").setup({})
		end,
	},
	{
		"cuducos/yaml.nvim",
		ft = { "yaml" }, -- optional
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
	},
	{
		"norcalli/nvim-colorizer.lua",
		config = function()
			require("colorizer").setup({
				vim = { mode = "background" },
				nix = { mode = "background" },
				lua = { mode = "background" },
				html = { mode = "background" },
				scss = { mode = "background" },
				css = { mode = "background" },
			})
		end,
	},
	{
		"hiphish/rainbow-delimiters.nvim",
		config = function()
			local rainbow = require("rainbow-delimiters")
			require("rainbow-delimiters.setup").setup({
				strategy = {
					-- global - highlight the entire buffer
					-- local - highlight subtree with cursor
					--
					-- Pick the strategy based on the buffer size
					[""] = function(bufnr)
						-- Disabled for very large files, global strategy for large files,
						-- local strategy otherwise
						local line_count = vim.api.nvim_buf_line_count(bufnr)
						if line_count > 10000 then
							return nil
						end
						return rainbow.strategy["local"]
					end,
				},
				highlight = {
					"RainbowDelimiterNormal",
					"RainbowDelimiterRed",
					"RainbowDelimiterNormal",
					"RainbowDelimiterOrange",
				},
				blacklist = {},
			})
		end,
	},
	{
		"nvim-lualine/lualine.nvim",
		config = function()
			require("lualine").setup({
				options = {
					icons_enabled = false,
					theme = function()
						local mccurdyc_colors = require("colors")
						return {
							normal = {
								a = { bg = mccurdyc_colors.yellow, fg = mccurdyc_colors.background, gui = "bold" },
								b = { bg = mccurdyc_colors.grey, fg = mccurdyc_colors.background },
								c = { bg = mccurdyc_colors.grey, fg = mccurdyc_colors.background },
							},
							insert = {
								a = { bg = mccurdyc_colors.green, fg = mccurdyc_colors.background, gui = "bold" },
								b = { bg = mccurdyc_colors.grey, fg = mccurdyc_colors.background },
								c = { bg = mccurdyc_colors.grey, fg = mccurdyc_colors.background },
							},
							visual = {
								a = { bg = mccurdyc_colors.blue, fg = mccurdyc_colors.foreground, gui = "bold" },
								b = { bg = mccurdyc_colors.grey, fg = mccurdyc_colors.background },
								c = { bg = mccurdyc_colors.grey, fg = mccurdyc_colors.background },
							},
							replace = {
								a = { bg = mccurdyc_colors.red, fg = mccurdyc_colors.background, gui = "bold" },
								b = { bg = mccurdyc_colors.grey, fg = mccurdyc_colors.background },
								c = { bg = mccurdyc_colors.grey, fg = mccurdyc_colors.background },
							},
							command = {
								a = { bg = mccurdyc_colors.green, fg = mccurdyc_colors.background, gui = "bold" },
								b = { bg = mccurdyc_colors.grey, fg = mccurdyc_colors.background },
								c = { bg = mccurdyc_colors.grey, fg = mccurdyc_colors.background },
							},
							inactive = {
								a = { bg = mccurdyc_colors.grey, fg = mccurdyc_colors.background, gui = "bold" },
								b = { bg = mccurdyc_colors.grey, fg = mccurdyc_colors.background },
								c = { bg = mccurdyc_colors.grey, fg = mccurdyc_colors.background },
							},
						}
					end,
					component_separators = " ",
					section_separators = " ",
					disabled_filetypes = {},
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = {
						"branch",
						{
							"diff",
							colored = true,
							symbols = {
								added = "+",
								modified = "~",
								removed = "-",
							},
						},
					},
					lualine_c = { "filename", "diagnostics" },
					lualine_x = { "encoding", "filetype" },
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
				inactive_sections = {
					lualine_a = {},
					lualine_b = {},
					lualine_c = { "filename" },
					lualine_x = { "location" },
					lualine_y = {},
					lualine_z = {},
				},
				tabline = {},
				extensions = {},
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = { "hrsh7th/nvim-cmp" },
	},
	{
		"hrsh7th/nvim-cmp",
		-- load cmp on InsertEnter
		event = "InsertEnter",
		-- these dependencies will only be loaded when cmp loads
		-- dependencies are always lazy-loaded unless specified otherwise
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-nvim-lsp-document-symbol",
			"hrsh7th/cmp-nvim-lsp-signature-help",
			"zjp-CN/nvim-cmp-lsp-rs", -- Apparently, there is some weird behavior specific to rust-analyzer - https://github.com/zjp-CN/nvim-cmp-lsp-rs/issues/1
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-nvim-lua",
			"hrsh7th/cmp-path",
			"saadparwaiz1/cmp_luasnip",
			"L3MON4D3/LuaSnip",
			"onsails/lspkind.nvim", -- vscode symbols
		},
		config = function()
			-- https://www.youtube.com/watch?v=_DnmphIwnjo
			-- :h ins-completion
			-- https://github.com/tjdevries/config_manager/blob/master/xdg_config/nvim/after/plugin/completion.lua
			local cmp = require("cmp")
			local lspkind = require("lspkind")
			local luasnip = require("luasnip")

			vim.opt.completeopt = { "menu", "menuone", "noselect" }
			vim.opt.pumheight = 5 -- Set the maximum height of the completion popup menu to 10 lines

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = {
					["<C-d>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-e>"] = cmp.mapping.abort(),
					["<C-n>"] = cmp.mapping.select_next_item({
						behavior = cmp.SelectBehavior.Insert,
					}),
					["<C-p>"] = cmp.mapping.select_prev_item({
						behavior = cmp.SelectBehavior.Insert,
					}),
					["<C-y>"] = cmp.mapping(
						cmp.mapping.confirm({
							behavior = cmp.ConfirmBehavior.Insert,
							select = true,
						}),
						{ "i", "c" }
					),
				},
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "buffer", max_item_count = 1, keyword_length = 4 },
					{ name = "path" },
				}),

				-- https://github.com/hrsh7th/nvim-cmp/wiki/Menu-Appearance#how-to-get-types-on-the-left-and-offset-the-menu
				window = {
					height = 5,
					completion = {
						winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
						col_offset = -3,
						side_padding = 0,
					},
					documentation = cmp.config.window.bordered({
						position = "bottom",
						max_height = 15,
						border = "rounded",
						winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder",
					}),
				},
				experimental = {
					ghost_text = false,
				},
				formatting = {
					fields = { "kind", "abbr", "menu" },
					format = function(entry, vim_item)
						local kind = lspkind.cmp_format({
							mode = "text",
							maxwidth = 20,
							ellipsis_char = "...", -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
							show_labelDetails = true, -- show labelDetails in menu. Disabled by default
						})(entry, vim_item)
						kind.menu = (
							({
								buffer = "[BUF]",
								nvim_lsp = "[LSP]",
								luasnip = "[SNIP]",
								path = "[Path]",
							})[entry.source.name] or "[OTHER]"
						)
						return kind
					end,
				},

				--[[
				" Disable cmp for a buffer
				autocmd FileType TelescopePrompt lua require('cmp').setup.buffer { enabled = false }
				--]]
			})

			-- https://github.com/hrsh7th/nvim-cmp?tab=readme-ov-file#recommended-configuration
			-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
			cmp.setup.cmdline({ "/", "?" }, {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
			})

			-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{ name = "cmdline" },
				}),
				matching = { disallow_symbol_nonprefix_matching = false },
			})

			-- Setup lspconfig AFTER cmp as in the suggested nvim-cmp config
			local lspconfig = require("lspconfig")
			local option = vim.api.nvim_set_option

			-- Enable completion triggered by <c-x><c-o>
			option("omnifunc", "v:lua.vim.lsp.omnifunc")

			-- Mappings.
			local opts = { noremap = true, silent = true }

			-- See `:help vim.lsp.*` for documentation on any of the below functions
			map("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
			map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
			map("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
			map("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
			map("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
			map("n", "<leader>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
			map("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
			map("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
			map("n", "[d", "<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>", opts)
			map("n", "]d", "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>", opts)

			local g = vim.g

			-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
			local servers = {
				"bashls",
				"dockerls",
				"terraformls",
				"lua_ls", -- lua-language-server
				"tflint",
				"nil_ls",
			}

			-- Use lsp formatting for Rust instead of none-ls
			local rust_group = vim.api.nvim_create_augroup("RustConfig", { clear = true })
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = rust_group,
				pattern = "*.rs",
				callback = function()
					vim.lsp.buf.format({ async = false })
				end,
			})

			-- NOTE: Call this base setup BEFORE per-language - https://github.com/hrsh7th/nvim-cmp/issues/1208#issuecomment-1281501620
			for _, lsp in ipairs(servers) do
				local capabilities = require("cmp_nvim_lsp").default_capabilities()
				lspconfig[lsp].setup({
					capabilities = capabilities,
				})
			end

			lspconfig["gopls"].setup({
				cmd = { "gopls" },
				settings = {
					gopls = {
						experimentalPostfixCompletions = true,
						-- https://github.com/golang/tools/blob/master/gopls/doc/analyzers.md
						analyses = { unusedparams = true, shadow = true },
						staticcheck = true,
					},
				},
				init_options = { usePlaceholders = true },
			})

			lspconfig["rust_analyzer"].setup({
				settings = {
					["rust-analyzer"] = {
						-- Enable all features
						cargo = {
							allFeatures = true,
							loadOutDirsFromCheck = true,
							runBuildScripts = true,

							-- Build all binaries by default (remove specific target)
							-- target = 'your-binary-name',  -- Comment this out
							-- Or specify features explicitly instead of allFeatures
							-- features = { 'feature1', 'feature2', 'tokio/full' },
							-- Additional cargo arguments to build all binaries
							extraArgs = { "--bins" },
							-- For workspace projects, you can specify the target dir
							-- targetDir = true,
						},
						-- Add clippy lints for extra help
						check = {
							allFeatures = true,
							command = "clippy",
							extraArgs = { "--no-deps" },
						},
						-- Enhanced completion
						completion = {
							postfix = {
								enable = false,
							},
						},
						-- Inlay hints
						inlayHints = {
							bindingModeHints = {
								enable = false,
							},
							chainingHints = {
								enable = true,
							},
							closingBraceHints = {
								enable = true,
								minLines = 25,
							},
							closureReturnTypeHints = {
								enable = "never",
							},
							lifetimeElisionHints = {
								enable = "never",
								useParameterNames = false,
							},
							maxLength = 25,
							parameterHints = {
								enable = true,
							},
							reborrowHints = {
								enable = "never",
							},
							renderColons = true,
							typeHints = {
								enable = true,
								hideClosureInitialization = false,
								hideNamedConstructor = false,
							},
						},
						-- Proc macro support
						procMacro = {
							enable = true,
							ignored = {
								["async-trait"] = { "async_trait" },
								["napi-derive"] = { "napi" },
								["async-recursion"] = { "async_recursion" },
							},
						},
					},
				},
			})
		end,
	},
})

-- Highlight line number instead of having icons in sign column
vim.fn.sign_define("DiagnosticSignError", {
	text = "",
	numhl = "DiagnosticLineNrError",
})
vim.fn.sign_define("DiagnosticSignWarn", {
	text = "",
	numhl = "DiagnosticLineNrWarn",
})
vim.fn.sign_define("DiagnosticSignInfo", {
	text = "",
	numhl = "DiagnosticLineNrInfo",
})
vim.fn.sign_define("DiagnosticSignHint", {
	text = "",
	numhl = "DiagnosticLineNrHint",
})

-- LEAVE LAST!
vim.diagnostic.config({
	signs = false,
	virtual_text = false,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
})
