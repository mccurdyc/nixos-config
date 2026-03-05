{ config, ... }: {
  home.file.".claude" = {
    source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.config/nixos-config/home-modules/shared/claude/config";
    recursive = true;
  };
}
