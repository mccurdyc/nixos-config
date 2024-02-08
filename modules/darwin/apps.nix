{ pkgs, ... }:

{
  homebrew = {
    enable = true;

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
