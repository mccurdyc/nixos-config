{ pkgs, ... }:

{
  homebrew = {
    enable = true;

    # `brew install` equivalent
    brews = [
      "wireguard-tools"
    ];

    # `brew install --cask` equivalent
    casks = [
      "1password"
      "obsidian"
      "firefox"
      "slack"
      "spotify"
      "zoom"
      "signal"
    ];
  };
}
