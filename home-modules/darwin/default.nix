{ pkgs, config, user, ... }:

{
  imports = [
    ../shared
  ];

  # The user should already exist, but we need to set this up so Nix knows
  # what our home directory is (https://github.com/LnL7/nix-darwin/issues/423).
  users.users."${user}" = {
    home = "/Users/${user}";
    shell = pkgs.zsh;
  };
}
