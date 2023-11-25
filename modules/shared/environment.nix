{ pkgs, ... }:

{
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
      ripgrep
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

    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      TERM = "xterm-256color";

      BROWSER = "firefox";
      DOCKER_DEFAULT_PLATFORM = "linux/amd64";

      FZF_DEFAULT_COMMAND = "fd --type f --hidden --exclude vendor --exclude .git";
      FZF_CTRL_T_COMMAND = "$FZF_DEFAULT_COMMAND";
      FZF_ALT_C_OPTS = "--preview 'tree -C {} | head -200'";

      FASTLY_CHEF_USERNAME = "cmccurdy";
      INFRA_SKIP_VERSION_CHECK = "true";

      # https://docs.github.com/en/authentication/managing-commit-signature-verification/telling-git-about-your-signing-key#telling-git-about-your-gpg-key
      GPG_TTY = "$(tty)";
    };
  };
}
