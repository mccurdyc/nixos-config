{ pkgs, user, options, ... }:

{
  imports = [
    ../shared
  ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home = {
    username = user;
    homeDirectory = pkgs.lib.mkForce "/home/${user}";
  };
}
