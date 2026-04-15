{ pkgs, ... }:

{
  home.sessionVariables = {
    EDITOR = "${pkgs.neovim}/bin/nvim";
    VISUAL = "${pkgs.neovim}/bin/nvim";

    BROWSER = "firefox";

    FZF_CTRL_T_COMMAND = "fd --type f --hidden --no-ignore --exclude vendor --exclude .git";
    FZF_ALT_C_OPTS = "--preview 'tree -C {} | head -200'";
  };
}
