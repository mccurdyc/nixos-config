nixpkgs: plugins: system: final: prev:
let
  buildVimPlugins = nixpkgs: system: plugins:
    let
      buildVimPlugin = system: plugin:
        let
          inherit (nixpkgs.legacyPackages.${system}) vimUtils;
        in
        vimUtils.buildVimPluginFrom2Nix plugin;
    in
    builtins.mapAttrs
      (pluginName: plugin:
        buildVimPlugin system {
          pname = pluginName;
          version = plugin.rev or "dirty";
          src = plugin;
        })
      plugins;
  vimPlugins = buildVimPlugins nixpkgs system plugins;
in
{
  vimPlugins = prev.vimPlugins // vimPlugins;
}
