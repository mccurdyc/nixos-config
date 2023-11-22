{ pkgs, ... }: {
  environment = {
    shells = with pkgs; [ zsh ]; # Default Shell

    systemPackages = with pkgs; [
      coreutils
      curl
      gcc
      git
      gnumake
      gnupg
      mosh
      neovim
      openssl
      tailscale
      wget
      zsh
      (writeShellScriptBin "docker-stop-all" ''
        docker stop $(docker ps -q)
        docker system prune -f
      '')
      (writeShellScriptBin "docker-prune-all" ''
        docker-stop-all
        docker rmi -f $(docker images -a -q)
        docker volume prune -f
      '')
    ];

    variables = import ./environment/variables.nix;
  };
}
