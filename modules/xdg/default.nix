{ pkgs
, lib
, config
, ...
}:
with lib; let
  cfg = config.modules.xdg;
in
{
  options.modules.xdg = { enable = mkEnableOption "xdg"; };
  config = mkIf cfg.enable {
    xdg.configFile = {
      nvim = {
        source = ../nvim/lua;
        recursive = true;
      };
      "pip/pip.conf".text = ''
        [global]
        target=/home/mccurdyc/site-packages/
      '';
      "zsh/zsh_history.default".text = ''
        : 0000000000:0;sudo nixos-rebuild switch --flake '.#fgnix'
        : 0000000000:0;nix-collect-garbage -d
        : 0000000000:0;date +%s
        : 0000000000:0;docker system prune --all --force
        : 0000000000:0;sudo du / -cha --max-depth=1 --exclude=/{proc,mnt} | sort -h
      '';
    };
  };
}
