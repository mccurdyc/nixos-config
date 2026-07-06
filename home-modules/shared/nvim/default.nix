{ pkgs, lib, config, ... }:
let
  pi-acp = pkgs.buildNpmPackage {
    pname = "pi-acp";
    version = "0.0.27";
    src = ./pi-acp;
    npmDepsHash = "sha256-oOfNZqRR9tDesrMFb+qf/4OBRCc4IkJRa9CtTkLgvCY=";
    dontNpmBuild = true;
    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib/pi-acp
      cp -r node_modules $out/lib/pi-acp/
      mkdir -p $out/bin
      makeWrapper \
        ${pkgs.nodejs}/bin/node \
        $out/bin/pi-acp \
        --add-flags "$out/lib/pi-acp/node_modules/pi-acp/dist/index.js"
      runHook postInstall
    '';
    nativeBuildInputs = [ pkgs.makeWrapper ];
  };
in
{
  home.packages = [
    pkgs.neovim-unwrapped
    pkgs.gnumake
    pkgs.imagemagick
    pkgs.luajitPackages.magick
    pi-acp
  ];

  home.shellAliases = {
    vimdiff = "nvim -d";
  };

  xdg.configFile.nvim = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/nixos-config/home-modules/shared/nvim/config";
    recursive = true;
  };
}
