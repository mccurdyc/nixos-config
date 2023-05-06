{ config
, lib
, pkgs
, inputs
, ...
}: {
  imports = [ ../../modules/default.nix ];
  config.modules = {
    nvim.enable = true;
    zsh.enable = true;
    ssh.enable = true;
    git.enable = true;
    gpg.enable = true;
    tmux.enable = true;
    home.enable = true;
    direnv.enable = true;
    packages.enable = true;
    packages.additional-packages = with pkgs; [
      awscli2
      infra
      kubectl
      kubernetes-helm
      kubie
      ssm-session-manager-plugin
      ruby_3_1
      terraform-docs
      terraform-ls
      tflint
      wireguard-tools
    ];
  };
}
