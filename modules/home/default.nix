{ pkgs
, lib
, config
, ...
}:
with lib; let
  cfg = config.modules.home;
in
{
  options.modules.home = { enable = mkEnableOption "home"; };
  config = mkIf cfg.enable {
    # Need to run `vale sync` to install styles.
    home.sessionPath = [
      "$HOME/go/bin"
      "$HOME/.cargo/bin"
      # gem env gemdir
      "$HOME/.local/share/gem/ruby/3.1.0/bin"
      # python -m ensurepip --default-pip
      "$HOME/.local/bin"
    ];

    xdg.configFile."yamllint/config".source = ../../static/yamllint/config;
  };
}
