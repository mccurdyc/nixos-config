require("nvim-treesitter.configs").setup {
  ensure_installed = {"comment", "lua", "rust", "yaml", "go", "hcl", "bash"},
  indent = {
    enable = true
  },
  highlight = {
    enable = true
  }
}
