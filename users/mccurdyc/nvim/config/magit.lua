-- https://github.com/jreybert/vimagit

-- https://github.com/jreybert/vimagit/issues/114#issuecomment-275660370
vim.cmd([[
  autocmd User VimagitBufferInit call system(g:magit_git_cmd . " add -A " . magit#git#top_dir())
]])

local g = vim.g

g.magit_discard_untracked_do_delete = 1
g.magit_default_fold_level = 2
