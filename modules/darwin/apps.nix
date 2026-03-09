{ pkgs, ... }:

{
  homebrew = {
    enable = true;
    caskArgs.appdir = "/Applications";
    onActivation = {
      autoUpdate = true;
      upgrade = true;
    };

    # `brew install --cask` equivalent
    casks = [
      "1password"
      "firefox"
      "ghostty"
      "obsidian"
      "raycast"
      "signal"
      "slack"
      "spotify"
      "zen-browser"
      "zoom"
    ];
  };
}
