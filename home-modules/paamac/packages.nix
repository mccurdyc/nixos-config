{ pkgs, ... }:
{
  home.packages = with pkgs; [
    llm-agents.pi
  ];
}
