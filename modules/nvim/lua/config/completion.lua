-- https://www.youtube.com/watch?v=_DnmphIwnjo
-- :h ins-completion
-- https://github.com/tjdevries/config_manager/blob/master/xdg_config/nvim/after/plugin/completion.lua
local cmp = require("cmp")
local lspkind = require("lspkind")
local luasnip = require("luasnip")

vim.opt.completeopt = {"menu", "menuone", "noselect"}

cmp.setup {
    mapping = {
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-e>"] = cmp.mapping.close(),
        ["<C-n>"] = cmp.mapping.select_next_item {
            behavior = cmp.SelectBehavior.Insert
        },
        ["<C-p>"] = cmp.mapping.select_prev_item {
            behavior = cmp.SelectBehavior.Insert
        },
        ["<C-y>"] = cmp.mapping(cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Insert,
            select = true
        }, {"i", "c"})
    },

    snippet = {expand = function(args) luasnip.lsp_expand(args.body) end},

    sources = cmp.config.sources({
        {name = "nvim_lua"}, {name = "luasnip"}, {name = "nvim_lsp"}
    }, {{name = "path"}, {name = "buffer", keyword_length = 5}}),

    formatting = {
        format = lspkind.cmp_format({
            mode = 'text',
            maxwidth = 50,
            ellipsis_char = '...',
            menu = {
                buffer = "[buf]",
                nvim_lsp = "[LSP]",
                nvim_lua = "[api]",
                path = "[path]",
                luasnip = "[snip]"
            }
        }),

        experimental = {native_menu = false, ghost_text = true}
    }

    --[[
" Disable cmp for a buffer
autocmd FileType TelescopePrompt lua require('cmp').setup.buffer { enabled = false }
--]]
}
