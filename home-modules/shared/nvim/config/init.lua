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

g.t_Co = 256
g.base16colorspace = 256

cmd("filetype plugin indent on")

autocmd("misc_aucmds", {
	[[FileType yaml setlocal ts=2 sts=2 sw=2 expandtab]],
}, true)

g.loaded_python_provider = 0
g.python_host_prog = "/usr/bin/python2"
g.python3_host_prog = "/usr/bin/python"
g.netrw_browsex_viewer = "xdg-open"

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
opt("termguicolors", true)
opt("syntax", "enable")
opt("hlsearch", false)
opt("splitbelow", true)
opt("signcolumn", "yes")
opt("splitright", true)
opt("showmode", false)
opt("foldminlines", 1)
opt("foldmethod", "indent")
opt("foldlevelstart", 20)
opt("foldenable", true)

local map = vim.api.nvim_set_keymap
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

-- Telescope
map("n", "<leader>f", ":lua require('telescope.builtin').live_grep()<CR>", opts)
map("n", "<C-p>", ":lua require('telescope.builtin').find_files()<CR>", opts)
map(
	"n",
	"<C-g>",
	":lua require('telescope.builtin').git_files({git_command={'git','diff','--name-only','origin/main'}})<CR>",
	opts
)

-- LSP
-- https://github.com/neovim/nvim-lspconfig/blob/da7461b596d70fa47b50bf3a7acfaef94c47727d/doc/lspconfig.txt#L444
-- https://neovim.discourse.group/t/jump-to-definition-in-vertical-horizontal-split/2605/14
map("n", "<leader>gd", ':lua require"telescope.builtin".lsp_definitions({jump_type="vsplit"})<CR>', opts)

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
	{
		url = "git@github.com:mccurdyc/base16-vim",
		lazy = false, -- make sure we load this during startup if it is your main colorscheme
		priority = 1000, -- make sure to load this before all the other start plugins
		config = function()
			vim.cmd([[colorscheme base16-eighties-minimal]])
		end,
	},
	"tpope/vim-fugitive",
	"tpope/vim-rhubarb",
	"tomtom/tcomment_vim",
	"dstein64/vim-startuptime", -- nvim -c :StartupTime
	{
		-- DEBUGGING
		"nvim-lua/plenary.nvim",
		config = function()
			local async = require("plenary.async")
			-- https://github.com/nvim-lua/plenary.nvim?tab=readme-ov-file#plenaryprofile
			-- require'plenary.profile'.start("profile.log", {flame = true})
			-- code to be profiled
			-- require'plenary.profile'.stop()
			-- inferno-flamegraph profile.log > flame.svg
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
			require("go").setup()
		end,
		event = { "CmdlineEnter" },
		ft = { "go", "gomod" },
		build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
	},
	{
		"rust-lang/rust.vim",
		ft = "rs",
	},
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
			"MunifTanjim/nui.nvim",
		},
		config = function()
			-- If you want icons for diagnostic errors, you'll need to define them somewhere:
			vim.fn.sign_define("DiagnosticSignError", { text = " ", texthl = "DiagnosticSignError" })
			vim.fn.sign_define("DiagnosticSignWarn", { text = " ", texthl = "DiagnosticSignWarn" })
			vim.fn.sign_define("DiagnosticSignInfo", { text = " ", texthl = "DiagnosticSignInfo" })
			vim.fn.sign_define("DiagnosticSignHint", { text = "󰌵", texthl = "DiagnosticSignHint" })

			require("neo-tree").setup({
				close_if_last_window = false, -- Close Neo-tree if it is the last window left in the tab
				popup_border_style = "rounded",
				enable_git_status = true,
				source_selector = { winbar = false, statusline = false },
				enable_diagnostics = true,
				icon = {
					folder_closed = "",
					folder_open = "",
					folder_empty = "󰜌",
					-- The next two settings are only a fallback, if you use nvim-web-devicons and configure default icons there
					-- then these will never be used.
					default = "*",
					highlight = "NeoTreeFileIcon",
				},
				modified = {
					symbol = "[+]",
					highlight = "NeoTreeModified",
				},
				name = {
					trailing_slash = false,
					use_git_status_colors = true,
					highlight = "NeoTreeFileName",
				},
				git_status = {
					symbols = {
						-- Change type
						added = "", -- or "✚", but this is redundant info if you use git_status_colors on the name
						modified = "", -- or "", but this is redundant info if you use git_status_colors on the name
						deleted = "✖", -- this can only be used in the git_status source
						renamed = "󰁕", -- this can only be used in the git_status source
						-- Status type
						untracked = "",
						ignored = "",
						unstaged = "󰄱",
						staged = "",
						conflict = "",
					},
				},
				-- A list of functions, each representing a global custom command
				-- that will be available in all sources (if not overridden in `opts[source_name].commands`)
				-- see `:h neo-tree-custom-commands-global`
				commands = {},
				window = {
					position = "left",
					width = 40,
					mapping_options = {
						noremap = true,
						nowait = true,
					},
					mappings = {
						["<cr>"] = "toggle_node",
						["P"] = { "toggle_preview", config = { use_float = true, use_image_nvim = true } },
						["o"] = { "open", nowait = false },
						["x"] = "open_split", -- split_with_window_picker
						["v"] = "open_vsplit", -- vsplit_with_window_picker
						["w"] = "open_with_window_picker",
						["<bs>"] = "close_node", -- close_all_subnodes
						["zM"] = "close_all_nodes",
						["O"] = "expand_all_nodes",
						["a"] = {
							"add",
							-- this command supports BASH style brace expansion ("x{a,b,c}" -> xa,xb,xc). see `:h neo-tree-file-actions` for details
							-- some commands may take optional config options, see `:h neo-tree-mappings` for details
							config = {
								show_path = "none", -- "none", "relative", "absolute"
							},
						},
						["A"] = "add_directory",
						["d"] = "delete",
						["r"] = "rename",
						["y"] = "copy_to_clipboard",
						["p"] = "paste_from_clipboard",
						["c"] = "copy",
						["m"] = "move",
						["q"] = "close_window",
						["R"] = "refresh",
						["?"] = "show_help",
						["<"] = "navigate_up",
						["."] = "set_root",
						["H"] = "toggle_hidden",
						["/"] = "fuzzy_finder",
						["#"] = "fuzzy_sorter",
						["og"] = { "order_by_git_status", nowait = false },
						["on"] = { "order_by_name", nowait = false },
						["i"] = "show_file_details",
					},
					fuzzy_finder_mappings = { -- define keymaps for filter popup window in fuzzy_finder_mode
						["<C-n>"] = "move_cursor_down",
						["<C-p>"] = "move_cursor_up",
					},
				},
				filesystem = {
					filtered_items = {
						visible = false, -- when true, they will just be displayed differently than normal items
						hide_dotfiles = true,
						hide_gitignored = true,
						hide_hidden = true, -- only works on Windows for hidden files/directories
						hide_by_name = {
							--"node_modules"
						},
						hide_by_pattern = { -- uses glob style patterns
							--"*.meta",
							--"*/src/*/tsconfig.json",
						},
						always_show = { -- remains visible even if other settings would normally hide it
							--".gitignored",
						},
						never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
							--".DS_Store",
							--"thumbs.db"
						},
						never_show_by_pattern = { -- uses glob style patterns
							--".null-ls_*",
						},
					},
				},
			})
		end,
	},
	{
		"hrsh7th/nvim-cmp",
		-- load cmp on InsertEnter
		event = "InsertEnter",
		-- these dependencies will only be loaded when cmp loads
		-- dependencies are always lazy-loaded unless specified otherwise
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-nvim-lua",
			"hrsh7th/cmp-path",
		},
		config = function()
			-- https://www.youtube.com/watch?v=_DnmphIwnjo
			-- :h ins-completion
			-- https://github.com/tjdevries/config_manager/blob/master/xdg_config/nvim/after/plugin/completion.lua
			local cmp = require("cmp")
			local lspkind = require("lspkind")
			local luasnip = require("luasnip")

			vim.opt.completeopt = { "menu", "menuone", "noselect" }

			cmp.setup({
				mapping = {
					["<C-d>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-e>"] = cmp.mapping.close(),
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
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				sources = cmp.config.sources({
					{ name = "buffer" },
					{ name = "buffer-lines" },
					{ name = "path" },
					{ name = "nvim_lua" },
					{ name = "luasnip" },
					{ name = "nvim_lsp" },
				}),
				formatting = {
					format = lspkind.cmp_format({
						mode = "text",
						maxwidth = 50,
						ellipsis_char = "...",
						menu = {
							buffer = "[BUF]",
							["buffer-lines"] = "[LBUF]", -- hyphened-key names need escaped
							nvim_lsp = "[LSP]",
							nvim_lua = "[api]",
							path = "[path]",
							luasnip = "[snip]",
						},
					}),
					experimental = { native_menu = false, ghost_text = true },
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
	"saadparwaiz1/cmp_luasnip",
	"onsails/lspkind.nvim",
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
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("telescope").setup({
				defaults = {
					vimgrep_arguments = {
						"rg",
						"--hidden",
						"--color=never",
						"--no-heading",
						"--with-filename",
						"--line-number",
						"--column",
						"--smart-case",
					},
					layout_config = { horizontal = { height = 0.8, width = 0.9 } },
					prompt_prefix = "> ",
					selection_caret = "> ",
					entry_prefix = "  ",
					initial_mode = "insert",
					selection_strategy = "closest",
					sorting_strategy = "descending",
					layout_strategy = "horizontal",
					file_sorter = require("telescope.sorters").get_fuzzy_file,
					file_ignore_patterns = {},
					generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
					path_display = absolute,
					winblend = 0,
					border = {},
					borderchars = {
						"─",
						"│",
						"─",
						"│",
						"╭",
						"╮",
						"╯",
						"╰",
					},
					color_devicons = false,
					use_less = true,
					set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
					file_previewer = require("telescope.previewers").vim_buffer_cat.new,
					grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
					qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
				},
				pickers = {
					buffers = { sort_lastused = true },
					find_files = {
						hidden = true,
						--- no_ignore = true,
						previewer = false,
						layout_config = { prompt_position = "top" },
					},
				},
				--[[extensions = {
				fzf = {
				    fuzzy = true,
				    override_generic_sorter = true,
				    override_file_sorter = true,
				    case_mode = "smart_case"
				}
			    }]]
			})

			-- load extensions after calling setup function
			-- require("telescope").load_extension("fzf")
		end,
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = { "hrsh7th/nvim-cmp" },
		config = function()
			local lspconfig = require("lspconfig")
			local util = require("lspconfig.util")
			local map = vim.api.nvim_set_keymap
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

			-- Highlight line number instead of having icons in sign column
			-- https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization#highlight-line-number-instead-of-having-icons-in-sign-column
			vim.cmd([[
			  highlight! DiagnosticLineNrError guibg=#f2777a guifg=#515151 gui=bold
			  highlight! DiagnosticLineNrWarn guibg=#ffcc66 guifg=#515151 gui=bold
			  highlight! DiagnosticLineNrInfo guibg=#d3d0c8 guifg=#515151 gui=bold
			  highlight! DiagnosticLineNrHint guibg=#d3d0c8 guifg=#515151 gui=bold

			  sign define DiagnosticSignError text= texthl=DiagnosticSignError linehl= numhl=DiagnosticLineNrError
			  sign define DiagnosticSignWarn text= texthl=DiagnosticSignWarn linehl= numhl=DiagnosticLineNrWarn
			  sign define DiagnosticSignInfo text= texthl=DiagnosticSignInfo linehl= numhl=DiagnosticLineNrInfo
			  sign define DiagnosticSignHint text= texthl=DiagnosticSignHint linehl= numhl=DiagnosticLineNrHint
			]])

			vim.diagnostic.config({
				virtual_text = false,
				signs = true,
				underline = true,
				update_in_insert = false,
				severity_sort = false,
			})

			-- https://github.com/ms-jpq/coq_nvim#autostart-coq
			-- g.coq_settings = {
			--     -- https://github.com/NixOS/nixpkgs/issues/168928#issuecomment-1109581739
			--     -- https://github.com/ms-jpq/coq_nvim/blob/coq/docs/CONF.md#specifics
			--     ["xdg"] = true,
			--     ["auto_start"] = "shut-up",
			--     ["display.icons.mode"] = "none",
			--     ["display.ghost_text.context"] = {"[", "]"},
			--     ["display.pum.source_context"] = {"[", "]"},
			--     ["match.exact_matches"] = 5,
			--     ["weights.prefix_matches"] = 3.0
			-- }
			--
			-- require("coq")

			-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
			local servers = {
				"rust_analyzer",
				"bashls",
				"dockerls",
				"terraformls",
				"tflint",
				"nil_ls",
			}
			-- https://github.com/hrsh7th/nvim-cmp/issues/1208#issuecomment-1281501620
			local function get_forced_lsp_capabilities()
				local capabilities = vim.lsp.protocol.make_client_capabilities()
				capabilities.textDocument.completion.completionItem.snippetSupport = true
				capabilities.textDocument.completion.completionItem.resolveSupport = {
					properties = {
						"documentation",
						"detail",
						"additionalTextEdits",
					},
				}
				return capabilities
			end

			local function my_lsp_on_attach(client, bufnr)
				local capabilities =
					require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
			end

			util.default_config = vim.tbl_extend("force", util.default_config, {
				autostart = true,
				on_attach = my_lsp_on_attach,
				capabilities = get_forced_lsp_capabilities(),
			})

			-- NOTE: Call setup last
			-- https://github.com/hrsh7th/nvim-cmp/issues/1208#issuecomment-1281501620
			for _, lsp in ipairs(servers) do
				lspconfig[lsp].setup({ on_attach = on_attach })
				-- lspconfig[lsp].setup(coq.lsp_ensure_capabilities())
				-- lspconfig[lsp].setup {capabilities = capabilities}
			end

			lspconfig["gopls"].setup({
				cmd = { "gopls" },
				on_attach = on_attach,
				capabilities = capabilities,
				settings = {
					gopls = {
						experimentalPostfixCompletions = true,
						analyses = { unusedparams = true, shadow = true },
						staticcheck = true,
					},
				},
				init_options = { usePlaceholders = true },
			})
		end,
	},
	{
		"folke/trouble.nvim",
		config = function()
			require("trouble").setup({
				-- settings without a patched font or icons
				icons = false,
				fold_open = "v", -- icon used for open folds
				fold_closed = ">", -- icon used for closed folds
				position = "bottom", -- position of the list can be: bottom, top, left, right
				height = 5, -- height of the trouble list when position is top or bottom
				width = 50, -- width of the list when position is left or right
				group = true, -- group results by file
				padding = false, -- add an extra new line on top of the list
				indent_lines = true, -- add an indent guide below the fold icons
				auto_open = false, -- automatically open the list when you have diagnostics
				auto_close = false, -- automatically close the list when you have no diagnostics
				auto_preview = false, -- automatically preview the location of the diagnostic. <esc> to close preview and go back to last window
				auto_fold = false, -- automatically fold a file trouble list at creation
				auto_jump = { "lsp_definitions" }, -- for the given modes, automatically jump if there is only a single result
				signs = {
					-- icons / text used for a diagnostic
					error = "ERR",
					warning = "WARN",
					hint = "HINT",
					information = "INFO",
				},
				mode = "document_diagnostics", -- "workspace_diagnostics", "document_diagnostics", "quickfix", "lsp_references", "loclist"
				action_keys = {
					-- key mappings for actions in the trouble list
					-- map to {} to remove a mapping, for example:
					-- close = {},
					close = "q", -- close the list
					cancel = "<esc>", -- cancel the preview and get back to your last window / buffer / cursor
					refresh = "r", -- manually refresh
					jump = { "<cr>", "<tab>" }, -- jump to the diagnostic or open / close folds
					open_split = { "<c-x>" }, -- open buffer in new split
					open_vsplit = { "<c-v>" }, -- open buffer in new vsplit
					open_tab = { "<c-t>" }, -- open buffer in new tab
					jump_close = { "o" }, -- jump to the diagnostic and close the list
					toggle_mode = "m", -- toggle between "workspace" and "document" diagnostics mode
					toggle_preview = "P", -- toggle auto_preview
					hover = "K", -- opens a small popup with the full multiline message
					preview = "p", -- preview the diagnostic location
					close_folds = { "zM", "zm" }, -- close all folds
					open_folds = { "zR", "zr" }, -- open all folds
					toggle_fold = { "zA", "za" }, -- toggle fold of current file
					previous = "k", -- previous item
					next = "j", -- next item
				},
				use_diagnostic_signs = true, -- enabling this will use the signs defined in your lsp client
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
					null_ls.builtins.diagnostics.cue_fmt,
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
					null_ls.builtins.formatting.gofumpt,
					null_ls.builtins.formatting.goimports,
					null_ls.builtins.formatting.goimports_reviser,
					null_ls.builtins.formatting.stylua,
					null_ls.builtins.formatting.nixpkgs_fmt,
					null_ls.builtins.formatting.rego,
					null_ls.builtins.formatting.just,
					null_ls.builtins.formatting.shfmt.with({ extra_args = { "-i", "4", "-ci" } }),
					null_ls.builtins.formatting.terraform_fmt,
					-- null_ls.builtins.formatting.yamlfmt
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
		"NeogitOrg/neogit",
		dependencies = {
			"nvim-lua/plenary.nvim", -- required
			"nvim-telescope/telescope.nvim", -- optional
			"sindrets/diffview.nvim", -- optional
			"ibhagwan/fzf-lua", -- optional
		},
		config = function()
			require("neogit").setup({})
		end,
	},
	{
		"hashivim/vim-terraform",
		config = function()
			local g = vim.g
			g.terraform_fmt_on_save = 1
		end,
	},
	{
		"cuducos/yaml.nvim",
		ft = { "yaml" }, -- optional
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-telescope/telescope.nvim", -- optional
		},
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			local configs = require("nvim-treesitter.configs")

			configs.setup({
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
				},
				sync_install = false,
				highlight = { enable = true },
				indent = { enable = true },
			})
		end,
	},
	{
		"p00f/nvim-ts-rainbow",
		config = function()
			require("nvim-treesitter.configs").setup({
				rainbow = {
					enable = true,
					extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
					max_file_lines = nil, -- Do not enable for files with more than n lines, int
					-- colors = {}, -- table of hex strings
					-- termcolors = {} -- table of colour name strings
				},
			})
		end,
	},
	{
		"nvim-lualine/lualine.nvim",
		config = function()
			require("lualine").setup({
				options = {
					icons_enabled = false,
					theme = "horizon",
					component_separators = "",
					section_separators = "",
					disabled_filetypes = {},
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = {
						"branch",
						{
							"diff",
							colored = true,
							color_added = "#66cccc",
							color_modified = "#ffcc66",
							color_removed = "#f2777a",
							symbols = {
								added = "+",
								modified = "~",
								removed = "-",
							},
						},
					},
					lualine_c = { "filename" },
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
})
