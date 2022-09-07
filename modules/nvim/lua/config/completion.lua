local cmp = require("cmp")

cmp.setup {
  snippet = {
    expand = function(args)
      vim.fn["UltiSnips#Anon"](args.body)
    end
  },
  mapping = {
    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-e>"] = cmp.mapping.close(),
    ["<C-y>"] = cmp.mapping.confirm(
      {
        select = true,
        behavior = cmp.ConfirmBehavior.Insert
      }
    )
  },
  sources = {
    {name = "nvim_lsp"},
    {name = "nvim_lua"},
    {name = "buffer"},
    {name = "path"},
    {name = "ultisnips"}
  }
}
