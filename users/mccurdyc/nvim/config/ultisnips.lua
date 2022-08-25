-- Plugin: https://github.com/sirver/UltiSnips

local g = vim.g

g.UltiSnipsJumpForwardTrigger = "<C-j>"
g.UltiSnipsJumpBackwardTrigger = "<C-k>"

-- Don't set this to <CR> or you won't be able to hit ENTER in Vim.
g.UltiSnipsExpandTrigger = "<C-l>"

g.UltiSnipsSnippetDirectories = [$HOME.'/dotfiles/vim-snippets/UltiSnips']
g.UltiSnipsEditSplit = "horizontal"
