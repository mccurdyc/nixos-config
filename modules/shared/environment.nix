{ pkgs, pkgs-unstable, ... }:

{
  environment = {
    shells = with pkgs; [ zsh ]; # Default Shell

    systemPackages = with pkgs; [
      coreutils
      curl
      cntr
      gcc
      git
      gnumake
      gnupg
      mosh
      openssl
      ripgrep
      wget
      zsh
      pkgs.neovim
      pkgs-unstable.tailscale
      ruby_3_2
    ];

    variables = {
      # https://daiderd.com/nix-darwin/manual/index.html#opt-environment.variables
      # If you screw the path up, export PATH=/run/current-system/sw/bin:$PATH
      PATH = [
        "$PATH"
        "\${HOME}/.local/share/gem/ruby/3.2.0/bin"
        "/opt/homebrew/bin"
      ];
      EDITOR = "nvim";
      VISUAL = "nvim";

      BROWSER = "firefox";
      DOCKER_DEFAULT_PLATFORM = "linux/amd64";

      FZF_CTRL_T_COMMAND = "fd --type f --hidden --exclude vendor --exclude .git";
      FZF_ALT_C_OPTS = "--preview 'tree -C {} | head -200'";

      FASTLY_CHEF_USERNAME = "cmccurdy";
      INFRA_SKIP_VERSION_CHECK = "true";

      # https://docs.github.com/en/authentication/managing-commit-signature-verification/telling-git-about-your-signing-key#telling-git-about-your-gpg-key
      GPG_TTY = "$(tty)";
    };
  };
}
