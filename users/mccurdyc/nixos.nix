{pkgs, ...}: {
  users.users.mccurdyc = {
    isNormalUser = true;
    home = "/home/mccurdyc";
    extraGroups = ["docker" "wheel"];
    shell = pkgs.zsh;
    # https://github.com/NixOS/nixpkgs/blob/8a053bc2255659c5ca52706b9e12e76a8f50dbdd/nixos/modules/config/users-groups.nix#L43
    # mkpasswd -m sha-512
    hashedPassword = "$6$IaUNMyUlY0sYKtbB$IuFPlLujAES4jpt1MmoTzcZa8QSDBTu1uRLFGk//CVXlMy6053Hsq/8hpORwtSxz.v3kDqUdIwrKPIqoydcfy.";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHsulhlLwS9YrVaO1DF3IJVB4vVMC4hZDmZ+0QZQFjfR mccurdyc@ipad"
    ];
  };
}
