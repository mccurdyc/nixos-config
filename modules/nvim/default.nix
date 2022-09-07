{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.nvim;
in {
  options.modules.nvim = {enable = mkEnableOption "nvim";};
  config = mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      # https://github.com/nix-community/home-manager/issues/1907#issuecomment-934316296
      extraConfig = ''
        luafile ${config.xdg.configHome}/nvim/main.lua
      '';
      vimdiffAlias = true;
      plugins = with pkgs.vimPlugins; [
        vim-surround
        vim-unimpaired
        tcomment_vim
        plenary-nvim
        telescope-fzf-native-nvim
        telescope-dap-nvim
        vim-fugitive
        vim-gh-line
        vim-go
        rust-vim
        nvim-dap-ui
        nvim-web-devicons
        coq_nvim
        {
          plugin = nvim-bqf;
          config = ''
            luafile ${config.xdg.configHome}/nvim/config/quickfix.lua
          '';
        }
        {
          plugin = formatter-nvim;
          config = ''
            luafile ${config.xdg.configHome}/nvim/config/formatter.lua
          '';
        }
        {
          plugin = telescope-nvim;
          config = ''
            luafile ${config.xdg.configHome}/nvim/config/telescope.lua
          '';
        }
        {
          plugin = nvim-tree-lua;
          config = ''
            luafile ${config.xdg.configHome}/nvim/config/nvim-tree.lua
          '';
        }
        {
          plugin = nvim-lspconfig;
          config = ''
            luafile ${config.xdg.configHome}/nvim/config/lsp.lua
          '';
        }
        {
          plugin = nvim-ale-diagnostic;
          config = ''
            luafile ${config.xdg.configHome}/nvim/config/ale.lua
          '';
        }
        {
          plugin = gitsigns-nvim;
          config = ''
            luafile ${config.xdg.configHome}/nvim/config/gitsigns.lua
          '';
        }
        {
          plugin = neogit;
          config = ''
            luafile ${config.xdg.configHome}/nvim/config/neogit.lua
          '';
        }
        {
          plugin = vim-terraform;
          config = ''
            luafile ${config.xdg.configHome}/nvim/config/terraform.lua
          '';
        }
        {
          plugin = nvim-treesitter;
          config = ''
            luafile ${config.xdg.configHome}/nvim/config/treesitter.lua
          '';
        }
        {
          plugin = nvim-ts-rainbow;
          config = ''
            luafile ${config.xdg.configHome}/nvim/config/rainbow.lua
          '';
        }
        {
          plugin = nvim-dap;
          config = ''
            luafile ${config.xdg.configHome}/nvim/config/dap.lua
          '';
        }
        {
          plugin = lualine-nvim;
          config = ''
            luafile ${config.xdg.configHome}/nvim/config/statusline.lua
          '';
        }
      ];
    };
  };
}
