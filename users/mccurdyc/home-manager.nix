{inputs, ...}: {
  config,
  lib,
  profile,
  pkgs,
  ...
}: let
  inherit (pkgs.stdenv) isDarwin;
  inherit (pkgs.stdenv) isLinux;

  # For our MANPAGER env var
  # https://github.com/sharkdp/bat/issues/1145
  manpager = pkgs.writeShellScriptBin "manpager" (
    if isDarwin
    then ''
      sh -c 'col -bx | bat -l man -p'
    ''
    else ''
      cat "$1" | col -bx | bat --language man --style plain
    ''
  );
in {
  home.stateVersion = "23.05";
  xdg.enable = true;

  home.sessionPath = [
    "$HOME/go/bin"
    "$HOME/.cargo/bin"
    # gem env gemdir
    "$HOME/.local/share/gem/ruby/3.1.0/bin"
    # python -m ensurepip --default-pip
    "$HOME/.local/bin"
  ];

  # Hide "last login" message on new terminal.
  home.file.".hushlogin".text = "";

  xdg.configFile."yamllint/config".text = ''
    rules:
      document-start:
        present: true
  '';

  imports = [
    ./modules/alacritty.nix
    ./modules/direnv.nix
    ./modules/git.nix
    ./modules/gpg.nix
    ./modules/nvim/default.nix
    ./modules/packages.nix
    ./modules/ssh.nix
    ./modules/tmux.nix
    ./modules/zsh.nix

    ./profiles/${profile}/home-manager.nix
  ];
}
