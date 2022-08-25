require("nvim-autopairs").setup(
  {
    map_cr = true, -- without completion plugin
    fast_wrap = {
      map = "<M-e>",
      chars = {"{", "[", "(", '"', "'"},
      pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
      offset = -1, -- Offset from pattern match
      end_key = "$",
      keys = "qwertyuiopzxcvbnmasdfghjkl",
      check_comma = true,
      highlight = "Search",
      highlight_grey = "Comment"
    }
  }
)
