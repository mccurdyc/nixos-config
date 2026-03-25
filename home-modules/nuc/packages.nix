{ pkgs, ... }: {
  # All packages consolidated into shared/
  home.packages = with pkgs; [
    claude-code
    opencode
    pi-coding-agent
  ];
}
