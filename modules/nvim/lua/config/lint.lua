local null_ls = require("null-ls")

null_ls.setup({
    -- format on save
    -- https://github.com/jose-elias-alvarez/null-ls.nvim/wiki/Formatting-on-save#code
    on_attach = function(client, bufnr)
        if client.supports_method("textDocument/formatting") then
            vim.api.nvim_clear_autocmds({group = augroup, buffer = bufnr})
            vim.api.nvim_create_autocmd("BufWritePre", {
                group = augroup,
                buffer = bufnr,
                callback = function()
                    -- on 0.8, you should use vim.lsp.buf.format({ bufnr = bufnr }) instead
                    vim.lsp.buf.formatting_seq_sync(nil, 1000, {"null-ls"})
                end
            })
        end
    end,
    sources = {
        null_ls.builtins.diagnostics.hadolint,
        null_ls.builtins.diagnostics.jsonlint,
        null_ls.builtins.diagnostics.luacheck,
        null_ls.builtins.diagnostics.markdownlint,
        -- null_ls.builtins.diagnostics.semgrep,
        -- null_ls.builtins.diagnostics.shellcheck,
        -- null_ls.builtins.diagnostics.staticcheck,
        null_ls.builtins.diagnostics.statix, null_ls.builtins.diagnostics.vale,
        null_ls.builtins.diagnostics.yamllint,
        -- null_ls.builtins.formatting.beautysh,
        -- null_ls.builtins.formatting.buf,
        -- null_ls.builtins.formatting.cbfmt,
        null_ls.builtins.formatting.fixjson,
        null_ls.builtins.formatting.gofumpt,
        -- null_ls.builtins.formatting.goimports,
        -- null_ls.builtins.formatting.goimports_reviser,
        null_ls.builtins.formatting.jq, null_ls.builtins.formatting.lua_format,
        null_ls.builtins.formatting.markdownlint,
        -- null_ls.builtins.formatting.alejandra,
        null_ls.builtins.formatting.nixpkgs_fmt,
        null_ls.builtins.formatting.rustfmt, null_ls.builtins.formatting.shfmt,
        -- null_ls.builtins.formatting.terraform_fmt,
        null_ls.builtins.formatting.yamlfmt
    }
})
