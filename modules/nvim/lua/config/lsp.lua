local lspconfig = require("lspconfig")
local util = require("lspconfig.util")
local map = vim.api.nvim_set_keymap
local option = vim.api.nvim_set_option

-- Enable completion triggered by <c-x><c-o>
option("omnifunc", "v:lua.vim.lsp.omnifunc")

-- Mappings.
local opts = {noremap = true, silent = true}

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
vim.cmd [[
  highlight! DiagnosticLineNrError guibg=#f2777a guifg=#515151 gui=bold
  highlight! DiagnosticLineNrWarn guibg=#ffcc66 guifg=#515151 gui=bold
  highlight! DiagnosticLineNrInfo guibg=#d3d0c8 guifg=#515151 gui=bold
  highlight! DiagnosticLineNrHint guibg=#d3d0c8 guifg=#515151 gui=bold

  sign define DiagnosticSignError text= texthl=DiagnosticSignError linehl= numhl=DiagnosticLineNrError
  sign define DiagnosticSignWarn text= texthl=DiagnosticSignWarn linehl= numhl=DiagnosticLineNrWarn
  sign define DiagnosticSignInfo text= texthl=DiagnosticSignInfo linehl= numhl=DiagnosticLineNrInfo
  sign define DiagnosticSignHint text= texthl=DiagnosticSignHint linehl= numhl=DiagnosticLineNrHint
]]

vim.diagnostic.config({
    virtual_text = false,
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = false
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
    "rust_analyzer", "bashls", "dockerls", "terraformls", "tflint", "rnix",
    "sumneko_lua"
}
-- https://github.com/hrsh7th/nvim-cmp/issues/1208#issuecomment-1281501620
local function get_forced_lsp_capabilities()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = true
    capabilities.textDocument.completion.completionItem.resolveSupport = {
        properties = {"documentation", "detail", "additionalTextEdits"}
    }
    return capabilities
end

local function my_lsp_on_attach(client, bufnr)
    local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp
                                                                          .protocol
                                                                          .make_client_capabilities())
end

util.default_config = vim.tbl_extend("force", util.default_config, {
    autostart = true,
    on_attach = my_lsp_on_attach,
    capabilities = get_forced_lsp_capabilities()
})

-- NOTE: Call setup last
-- https://github.com/hrsh7th/nvim-cmp/issues/1208#issuecomment-1281501620
for _, lsp in ipairs(servers) do
    lspconfig[lsp].setup {on_attach = on_attach}
    -- lspconfig[lsp].setup(coq.lsp_ensure_capabilities())
    -- lspconfig[lsp].setup {capabilities = capabilities}
end

lspconfig['gopls'].setup {
    cmd = {'gopls'},
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        gopls = {
            experimentalPostfixCompletions = true,
            analyses = {unusedparams = true, shadow = true},
            staticcheck = true
        }
    },
    init_options = {usePlaceholders = true}
}
