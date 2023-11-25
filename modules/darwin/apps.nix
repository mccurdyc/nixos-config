{ pkgs, ... }:

{
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = false;
      cleanup = "zap";
    };

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
    ];
  };
}
