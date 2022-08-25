require("bqf").setup(
  {
    auto_enable = true,
    auto_resize_height = true,
    preview = {
      auto_preview = false
    },
    func_map = {
      vsplit = "",
      ptogglemode = "z,",
      stoggleup = ""
    },
    filter = {
      fzf = {
        action_for = {["ctrl-s"] = "split"},
        extra_opts = {"--bind", "ctrl-o:toggle-all", "--prompt", "> "}
      }
    }
  }
)
