{ pkgs, ... }:

{
  homebrew = {
    enable = true;
    caskArgs.appdir = "/Applications";
    onActivation = {
      cleanup = "uninstall";
      autoUpdate = true;
      upgrade = true;
    };

    # `brew install --cask` equivalent
    casks = [
      "1password"
      "obsidian"
      "firefox"
      "zen-browser"
      "slack"
      "spotify"
      "zoom"
      "signal"
      "ghostty"
    ];
  };
}
