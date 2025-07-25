-- Based on: https://github.com/mccurdyc/base16-vim/blob/master/colors/base16-mccurdyc-minimal.vim
vim.g.t_Co = 256
vim.g.base16colorspace = 256
vim.o.termguicolors = true

-- Color palette
local colors = {
	-- Color
	red = "#ff5f5f", -- red (error)
	yellow = "#ffa500", -- orange (warning)
	green = "#5fd787", -- green (good)
	blue = "#2950c5", -- blue
	-- Black and White
	background = "#040405", -- as black as I could make it without neovim tripping out at #040404; bug for another day
	almost_black = "#0d0d0d", -- almost black
	dark_grey = "#1d1d1d", -- dark grey
	grey = "#2d2d2d", -- grey
	comment = "#5d5d5d", -- comment
	light_grey = "#d3d0c8", -- light grey
	foreground = "#e4e4e4", -- foreground
	white = "#eeeeee", -- white
	pure_white = "#ffffff", -- pure white
}

-- Set terminal colors
vim.g.terminal_color_0 = "#040405"
vim.g.terminal_color_1 = "#ff5f5f"
vim.g.terminal_color_2 = "#5fd787"
vim.g.terminal_color_3 = "#ffa500"
vim.g.terminal_color_4 = "#2950c5"
vim.g.terminal_color_5 = "#2950c5"
vim.g.terminal_color_6 = "#2950c5"
vim.g.terminal_color_7 = "#eeeeee"
vim.g.terminal_color_8 = "#4e4e4e"
vim.g.terminal_color_9 = "#ff5f5f"
vim.g.terminal_color_10 = "#5fd787"
vim.g.terminal_color_11 = "#ffa500"
vim.g.terminal_color_12 = "#2950c5"
vim.g.terminal_color_13 = "#2950c5"
vim.g.terminal_color_14 = "#2950c5"
vim.g.terminal_color_15 = "#eeeeee"

-- Clear existing highlights and set colorscheme name
vim.cmd("hi clear")
vim.cmd("syntax reset")
vim.g.colors_name = "base16-mccurdyc-minimal"

-- Helper function to set highlights
local function hi(group, opts)
	vim.api.nvim_set_hl(0, group, opts)
end

-- Diff highlighting
hi("DiffAdd", { fg = colors.background, bg = colors.green })
hi("DiffChange", { fg = colors.background, bg = colors.yellow })
hi("DiffDelete", { fg = colors.background, bg = colors.red })
hi("DiffText", { fg = colors.dark_grey, bg = colors.green, bold = true })
hi("DiffAdded", { fg = colors.green, bg = colors.background })
hi("DiffFile", { fg = colors.yellow, bg = colors.background, bold = true })
hi("DiffNewFile", { fg = colors.green, bg = colors.background })
hi("DiffLine", { fg = colors.yellow, bg = colors.background, bold = true })
hi("DiffRemoved", { fg = colors.red, bg = colors.background })

-- Git highlighting
hi("gitcommitOverflow", { fg = colors.red })
hi("gitcommitSummary", { fg = colors.light_grey })
hi("gitcommitComment", { fg = colors.light_grey })
hi("gitcommitUntracked", { fg = colors.green })
hi("gitcommitDiscarded", { fg = colors.dark_grey })
hi("gitcommitSelected", { fg = colors.blue })
hi("gitcommitHeader", { fg = colors.white })
hi("gitcommitSelectedType", { fg = colors.foreground })
hi("gitcommitUnmergedType", { fg = colors.foreground })
hi("gitcommitDiscardedType", { fg = colors.foreground })
hi("gitcommitBranch", { fg = colors.comment, bold = true })
hi("gitcommitUntrackedFile", { fg = colors.dark_grey })
hi("gitcommitUnmergedFile", { fg = colors.comment, bold = true })
hi("gitcommitDiscardedFile", { fg = colors.comment, bold = true })
hi("gitcommitSelectedFile", { fg = colors.grey, bold = true })

-- Remove background, make bold and change Changes to be yellow
hi("GitGutterAdd", { fg = colors.green, bg = "NONE", bold = true })
hi("GitGutterChange", { fg = colors.yellow, bg = "NONE", bold = true })
hi("GitGutterDelete", { fg = colors.red, bg = "NONE", bold = true })
hi("GitGutterChangeDelete", { fg = colors.red, bg = "NONE", bold = true })

-- NERDTree highlighting
hi("NERDTreeDirSlash", { fg = colors.yellow })
hi("NERDTreeExecFile", { fg = colors.yellow })

-- FZFLua
hi("FzfLuaNormal", { fg = colors.white, bg = colors.background })

-- Spelling highlighting
hi("SpellBad", { sp = colors.yellow, undercurl = true })

-- Diagnostics
hi("DiagnosticWarn", { sp = colors.yellow })
hi("DiagnosticError", { sp = colors.red, underline = true })
hi("DiagnosticInfo", { sp = colors.light_grey, underline = true })
hi("DiagnosticHint", { sp = colors.light_grey, underline = true })
hi("DiagnosticLineNrWarn", { fg = colors.background, bg = colors.yellow, bold = true })
hi("DiagnosticLineNrError", { fg = colors.background, bg = colors.red, bold = true })
hi("DiagnosticLineNrInfo", { fg = colors.background, bg = colors.light_grey, bold = true })
hi("DiagnosticLineNrHint", { fg = colors.background, bg = colors.light_grey, bold = true })

-- Debug adapter protocol (DAP)
hi("DapBreakpoint", { fg = colors.green, bg = colors.background, bold = true })
hi("DapStopped", { fg = colors.red, bg = colors.background, bold = true })

-- Git messenger
hi("gitmessengerPopupNormal", { fg = colors.green, bg = colors.yellow })
hi("gitmessengerHeader", { fg = colors.foreground, bg = colors.yellow, bold = true })
hi("gitmessengerHash", { fg = colors.grey, bg = colors.yellow, bold = true })
hi("gitmessengerHistory", { fg = colors.background, bg = colors.yellow, bold = true })

-- Rainbow delimiters
hi("RainbowDelimiterNormal", { fg = colors.grey })
hi("RainbowDelimiterRed", { fg = colors.red })
hi("RainbowDelimiterOrange", { fg = colors.yellow })

hi("TroubleBasename", { fg = colors.yellow })
hi("TroubleFilename", { fg = colors.yellow })
hi("TroubleDirectory", { fg = colors.yellow })
hi("TroubleIconDirectory", { fg = colors.yellow })
hi("TroubleCount", { fg = colors.green })
hi("TroubleCode", { fg = colors.red })
hi("TroubleText", { fg = colors.grey })
hi("TroubleNormal", { fg = colors.grey, bg = colors.background })
hi("TroubleNormalNC", { fg = colors.grey, bg = colors.background }) -- not focused window

hi("LazyNormal", { fg = colors.foreground, bg = "NONE" })
hi("LazyButton", { fg = colors.background, bg = colors.yellow })
hi("LazyComment", { fg = colors.foreground, bg = colors.background })
hi("LazyH1", { fg = colors.foreground, bg = colors.background })
hi("LazyH2", { fg = colors.foreground, bg = colors.background })

-- Vim editor colors
hi("Normal", { fg = colors.foreground, bg = colors.background })
hi("NormalFloat", { fg = colors.foreground, bg = colors.dark_grey })
hi("FloatBorder", { fg = colors.yellow, bg = colors.dark_grey, bold = true })
hi("Special", { fg = colors.yellow, bg = colors.background })
hi("Bold", { bold = true })
hi("Debug", { fg = colors.yellow })
hi("Directory", { fg = colors.yellow })
hi("Error", { fg = colors.red, bg = colors.background })
hi("ErrorMsg", { fg = colors.background, bg = colors.red })
hi("Exception", { fg = colors.background })
hi("FoldColumn", { fg = colors.comment, bg = colors.comment })
hi("Folded", { fg = colors.comment, bg = colors.dark_grey })
hi("IncSearch", { fg = colors.grey, bg = colors.yellow })
hi("Macro", { fg = colors.light_grey })
hi("ModeMsg", { fg = colors.background })
hi("MoreMsg", { fg = colors.grey })
hi("Question", { fg = colors.foreground })
hi("Search", { fg = colors.background, bg = colors.yellow })
hi("Substitute", { fg = colors.background, bg = colors.yellow })
hi("SpecialKey", { fg = colors.green })
hi("TooLong", { fg = colors.green })
hi("Underlined", { fg = colors.yellow })
hi("Visual", { bg = colors.dark_grey, fg = "NONE" })
hi("VisualNOS", { fg = colors.yellow })
hi("WarningMsg", { fg = colors.yellow })
hi("WildMenu", { fg = colors.background, bg = colors.dark_grey })
hi("Title", { fg = colors.foreground })
hi("Conceal", { fg = colors.foreground, bg = colors.red })
hi("jsonQuote", { fg = "NONE", bg = "NONE" })
hi("jsonString", { fg = "NONE", bg = "NONE" })
hi("Cursor", { fg = colors.background, bg = colors.foreground })
hi("NonText", { fg = colors.grey })

-- Remove the sign and line column background
hi("LineNr", { fg = colors.dark_grey, bg = "NONE", bold = true })
hi("CursorLine", { bg = colors.almost_black, bold = true })
hi("CursorLineNr", { fg = colors.grey, bg = colors.background, bold = true })
hi("SignColumn", { fg = "NONE", bg = "NONE", bold = true })
hi("StatusLine", { fg = colors.yellow, bg = colors.comment })
hi("StatusLineNC", { fg = colors.yellow, bg = colors.comment })
hi("VertSplit", { fg = colors.green, bg = colors.comment })
hi("ColorColumn", { bg = colors.almost_black })
hi("CursorColumn", { bg = colors.almost_black })
hi("QuickFixLine", { bg = colors.dark_grey, bold = true })
hi("PMenu", { fg = colors.foreground, bg = colors.dark_grey })
hi("PMenuSel", { bg = colors.dark_grey, bold = true })
hi("TabLine", { fg = colors.blue, bg = colors.yellow })
hi("TabLineFill", { fg = colors.blue, bg = colors.yellow })
hi("TabLineSel", { fg = colors.grey, bg = colors.yellow })

-- treesitter
hi("@punctuation.special", { fg = colors.red })
hi("@punctuation.bracket", { fg = colors.red })
hi("@punctuation.delimiter", { fg = colors.comment }) -- for Rust's :: and ;
hi("@keyword", { fg = colors.foreground })
hi("@constant", { fg = colors.foreground })
hi("@variable", { fg = colors.foreground })
hi("@function", { fg = colors.yellow })
hi("@function.call", { fg = colors.yellow })
hi("@method", { fg = colors.yellow })
hi("@method.call", { fg = colors.yellow })
hi("@parameter", { fg = colors.foreground })
hi("@field", { fg = colors.foreground })
hi("@property", { fg = colors.foreground })
hi("@constructor", { fg = colors.foreground })
hi("@conditional", { fg = colors.foreground })
hi("@repeat", { fg = colors.red })
hi("@label", { fg = colors.foreground })
hi("@character.special", { fg = colors.foreground })
hi("@attribute.builtin", { fg = colors.foreground })
hi("@function.builtin", { fg = colors.foreground })
hi("@string", { fg = colors.light_grey })
hi("@string.escape", { fg = colors.red })
hi("@string.regexp", { fg = colors.red })
hi("@string.special", { fg = colors.red })
hi("@text", { fg = colors.foreground })
hi("@text.literal", { fg = colors.foreground })
hi("@text.uri", { fg = colors.light_grey })
hi("@number", { fg = colors.light_grey })
hi("@boolean", { fg = colors.light_grey })
hi("@tag", { fg = colors.grey })
hi("@type", { fg = colors.light_grey })
hi("@type.builtin", { fg = colors.light_grey })
hi("@include", { fg = colors.grey })
hi("@operator", { fg = colors.red })
hi("@exception", { fg = colors.red })
hi("@diff.plus", { fg = colors.green })
hi("@diff.minus", { fg = colors.red })
hi("@diff.delta", { fg = colors.yellow })
-- for Rust's std, collections, crate, my_module
hi("@module", { fg = colors.light_grey })
hi("@namespace", { fg = colors.light_grey })
hi("@module.builtin", { fg = colors.green })
hi("@comment", { fg = colors.comment })
hi("@tag.builtin", { fg = colors.foreground })
hi("@constant.builtin", { fg = colors.foreground })
hi("@variable.builtin", { fg = colors.foreground })
hi("@variable.parameter.builtin", { fg = colors.foreground })

-- Export the colors table so it can be required by other modules
return colors
