local g = vim.g

vim.cmd [[hi link ALEWarningSign String]]
vim.cmd [[hi link ALEErrorSign WarningMsg]]
vim.cmd [[hi link ALEStyleError error]]
vim.cmd [[hi link ALEStyleWarning error]]
vim.cmd [[hi link ALEError error]]
vim.cmd [[hi link AleWarning error]]

g.ale_echo_msg_format = "[%linter%] [%severity%] %s"
g.ale_echo_msg_error_str = "ERR"
g.ale_echo_msg_info_str = "INFO"
g.ale_echo_msg_warning_str = "WARN"
g.ale_completion_enabled = 0
g.ale_completion_autoimport = 1
g.ale_sign_column_always = 1
g.ale_sign_error = "▸"
g.ale_sign_warning = "▸"
g.ale_open_list = 1
g.ale_keep_list_window_open = 0

-- Rust
g.ale_rust_cargo_check_all_targets = 1

-- Terraform
g.ale_terraform_langserver_executable = "terraform-lsp"
g.ale_terraform_langserver_options = ""
g.ale_terraform_terraform_executable = "terraform"
g.ale_terraform_tflint_executable = "" -- disable tflint
g.ale_terraform_tflint_options = ""

-- Go
g.ale_go_staticcheck_lint_package = 1
g.ale_go_staticcheck_options = ""

-- Use quickfix instead of loclist
-- https://github.com/dense-analysis/ale#5xiii-how-can-i-use-the-quickfix-list-instead-of-the-loclist
g.ale_set_loclist = 0
g.ale_set_quickfix = 1

-- Only lint on save
-- https://github.com/dense-analysis/ale#5xii-how-can-i-run-linters-only-when-i-save-files
g.ale_lint_on_text_changed = "never"
g.ale_lint_on_insert_leave = 0
g.ale_lint_on_save = 1
g.ale_fix_on_save = 1
g.ale_lint_on_enter = 0

-- Rust
g.ale_rust_cargo_use_clippy = 1
g.ale_rust_rustfmt_options = "--edition=2021"

-- YAML
g.ale_yaml_yamllint_options = "{extends: default, rules: {line-length: disable}}"

-- -- ALE supported tools - https://github.com/dense-analysis/ale/blob/master/supported-tools.md
-- -- :ALEInfo
g.ale_linters = {
  ["go"] = {"gopls", "staticcheck", "gosimple"},
  ["rust"] = {"rustc", "analyzer", "cargo"},
  ["terraform"] = {"terraform", "terraform_lsp", "tflint"},
  ["docker"] = {"hadolint"},
  ["json"] = {"jsonlint"},
  ["md"] = {"markdownlint"}
}

g.ale_linters_ignore = {
  ["docker"] = {"dockerfile_lint"}
}

g.ale_fixers = {
  ["*"] = {"trim_whitespace"},
  ["go"] = {"gofmt", "goimports"},
  ["rust"] = {"rustfmt"},
  ["terraform"] = {"terraform"},
  ["json"] = {"jq"},
  ["md"] = {"markdownlint"}
}
