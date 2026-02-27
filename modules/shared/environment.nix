{ pkgs, ... }:

# User-session variables (EDITOR, BROWSER, etc.) live in
# home-modules/shared/environment.nix

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
      openssl
      ripgrep
      wget
      zsh
      neovim
      tailscale
    ];

    variables = {
      # https://daiderd.com/nix-darwin/manual/index.html#opt-environment.variables
      # If you screw the path up, export PATH=/run/current-system/sw/bin:$PATH
      PATH = [
        "$PATH"
        "/opt/homebrew/bin"
      ];
    };
  };
}
