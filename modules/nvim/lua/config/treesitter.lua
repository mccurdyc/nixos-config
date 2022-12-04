require("nvim-treesitter.configs").setup {
    -- NixOS is a RO filesystem, we don't want nvim trying to install things for us.
    -- ensure_installed = {"comment", "lua", "rust", "yaml", "go", "hcl", "bash"},
    sync_install = false,
    auto_install = false,
    indent = {enable = true},
    highlight = {enable = true}
}
