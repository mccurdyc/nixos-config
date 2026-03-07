{ pkgs, ... }: {
  # All packages consolidated into shared/
  home.packages = with pkgs; [
    opencode
    pi-coding-agent
  ];
}
