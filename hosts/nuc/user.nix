{ config
, lib
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
    packages.enable = true;
  };
}
