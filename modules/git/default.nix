{ pkgs
, lib
, config
, ...
}:
with lib; let
  cfg = config.modules.git;
in
{
  options.modules.git = { enable = mkEnableOption "git"; };
  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      userName = "Colton J. McCurdy";
      userEmail = "mccurdyc22@gmail.com";
      signing = {
        key = "9CD9D30EBB7B1EEC";
        signByDefault = true;
      };
      extraConfig = {
        init = { defaultBranch = "main"; };
        core = {
          excludesfile = "$NIXOS_CONFIG_DIR/scripts/gitignore";
        };
      };
      aliases = {
        l = "log --graph --topo-order --abbrev-commit --date=short --decorate --all --boundary";
        ll = "log --graph --all  --decorate --oneline";
        ls = "log --pretty=format:\"%C(green)%h %C(yellow)[%ad]%Cred%d %Creset%s%Cblue [%cn]\" --decorate --date=relative";
        ld = "log --all --graph --abbrev-commit --decorate --pretty=format:\"%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n %C(white)%s%C(reset) %C(dim white)- %an%C(reset)\"";
        d = "difftool";
        m = "mergetool";
      };
    };

    programs.gitui = {
      enable = true;
    };
  };
}
