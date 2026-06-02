{ pkgs, ... }:
{
  # All packages consolidated into shared/
  home.packages = with pkgs; [
    llm-agents.pi
    android-tools # supernote
  ];
}
