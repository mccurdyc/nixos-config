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
    # force it to create the directory
    home.file."src/github.com/mccurdyc/.keep".text = "";
    home.file.".vale.ini".text = ''
      StylesPath = styles
      Vocab = Blog

      [*.md]
      BasedOnStyles = Vale, write-good
    '';
    home.sessionPath = [
      "$HOME/go/bin"
      # gem env gemdir
      "$HOME/.local/share/gem/ruby/3.1.0/bin"
    ];
  };
}
