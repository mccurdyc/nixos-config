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
      "1password-cli"
      "ghostty"
      "monitorcontrol"
      "obsidian"
      "raycast"
      "signal"
      "slack"
      "spotify"
      "zen"
    ];
  };
}
