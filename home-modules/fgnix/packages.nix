{ pkgs, ... }: {
  home.packages = with pkgs; [
    python311Packages.google-compute-engine
  ];
}
