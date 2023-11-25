{ pkgs, user, ... }:

{
  users.users."${user}"= {
    home = "/Users/${user}";
    shell = pkgs.zsh;
  };
}
