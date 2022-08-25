local opt = opt
local autocmd = autocmd
local g = vim.g

autocmd(
  "lang_go_aucmds",
  {
    [[Filetype go set nolist]]
  },
  true
)

-- Plugin: https://github.com/fatih/vim-go
-- No gofmt on save. Use ALE.
g.go_fmt_autosave = 0
g.go_autodetect_gopath = 1
g.go_snippet_engine = ""

-- Use the LSP
g.go_auto_type_info = 0
g.go_def_mapping_enabled = 0
g.go_code_completion_enabled = 0
g.go_doc_keywordprg_enabled = 0
g.go_echo_go_info = 0
g.go_fmt_fail_silently = 0
g.go_list_type = "quickfix"
g.go_test_show_name = 1
g.go_list_autoclose = 0

-- https://github.com/neoclide/coc.nvim/issues/472#issuecomment-475848284
g.go_template_autocreate = 0
g.go_decls_mode = "fzf"
g.go_term_enabled = 1
g.go_term_height = 20
g.go_term_mode = "split"

-- Plugin: https://github.com/sebdah/vim-delve
-- Open Delve with a horizontal split rather than a vertical split.
g.delve_new_command = "new"
