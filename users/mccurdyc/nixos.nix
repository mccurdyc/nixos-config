{
  pkgs,
  inputs,
  ...
}: {
  environment.pathsToLink = [
    "/share/zsh" # required for zsh autocomplete
    "/share/nix-direnv"
  ];

  # Add ~/.local/bin to PATH
  environment.localBinInPath = true;

  programs.zsh.enable = true;

  users = {
    mutableUsers = false;
    users.mccurdyc = {
      isNormalUser = true;
      home = "/home/mccurdyc";
      extraGroups = ["docker" "wheel"];
      shell = pkgs.zsh;
      hashedPassword = "$6$d5uf.fUvF9kZ8iwH$/Bm6m3Hk82rj2V4d0pba1u6vCXIh/JLURv6Icxf1ok0heX1oK6LwSIXSeIOPriBLBnpq3amOV.pWLas0oPeCw1";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO2cxynJf1jRyVzsOjqRYVkffIV2gQwNc4Cq4xMTcsmN"
      ];
    };
  };
}
