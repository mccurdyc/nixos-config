{ config
, lib
, pkgs
, inputs
, ...
}: {
  imports = [ ../../modules/default.nix ];
  config.modules = {
    # gui
    # TODO

    # cli
    nvim.enable = true;
    zsh.enable = true;
    ssh.enable = true;
    git.enable = true;
    gpg.enable = true;
    tmux.enable = true;
    home.enable = true;

    # system
    xdg.enable = true;
    packages.enable = true;
    packages.additional-packages = with pkgs; [
      awscli2
      infra
      kubectl
      kubernetes-helm
      kubie
      wireguard-tools
    ];
  };
}
