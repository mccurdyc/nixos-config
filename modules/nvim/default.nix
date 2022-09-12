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
      plugins = with pkgs; [
        vimPlugins.vim-surround
        vimPlugins.vim-unimpaired
        vimPlugins.tcomment_vim
        vimPlugins.plenary-nvim
        vimPlugins.telescope-fzf-native-nvim
        vimPlugins.telescope-dap-nvim
        vimPlugins.vim-fugitive
        vimPlugins.vim-gh-line
        vimPlugins.vim-go
        vimPlugins.rust-vim
        vimPlugins.nvim-dap-ui
        vimPlugins.nvim-web-devicons
        vimPlugins.coq_nvim
        {
          plugin = vimPlugins.base16-vim-mccurdyc;
          config = ''
            colorscheme base16-eighties-minimal
          '';
        }
        {
          plugin = vimPlugins.nvim-bqf;
          config = ''
            luafile ${config.xdg.configHome}/nvim/config/quickfix.lua
          '';
        }
        {
          plugin = vimPlugins.formatter-nvim;
          config = ''
            luafile ${config.xdg.configHome}/nvim/config/formatter.lua
          '';
        }
        {
          plugin = vimPlugins.telescope-nvim;
          config = ''
            luafile ${config.xdg.configHome}/nvim/config/telescope.lua
          '';
        }
        {
          plugin = vimPlugins.nvim-tree-lua;
          config = ''
            luafile ${config.xdg.configHome}/nvim/config/nvim-tree.lua
          '';
        }
        {
          plugin = vimPlugins.nvim-lspconfig;
          config = ''
            luafile ${config.xdg.configHome}/nvim/config/lsp.lua
          '';
        }
        {
          plugin = vimPlugins.nvim-ale-diagnostic;
          config = ''
            luafile ${config.xdg.configHome}/nvim/config/ale.lua
          '';
        }
        {
          plugin = vimPlugins.gitsigns-nvim;
          config = ''
            luafile ${config.xdg.configHome}/nvim/config/gitsigns.lua
          '';
        }
        {
          plugin = vimPlugins.neogit;
          config = ''
            luafile ${config.xdg.configHome}/nvim/config/neogit.lua
          '';
        }
        {
          plugin = vimPlugins.vim-terraform;
          config = ''
            luafile ${config.xdg.configHome}/nvim/config/terraform.lua
          '';
        }
        {
          plugin = vimPlugins.nvim-treesitter;
          config = ''
            luafile ${config.xdg.configHome}/nvim/config/treesitter.lua
          '';
        }
        {
          plugin = vimPlugins.nvim-ts-rainbow;
          config = ''
            luafile ${config.xdg.configHome}/nvim/config/rainbow.lua
          '';
        }
        {
          plugin = vimPlugins.nvim-dap;
          config = ''
            luafile ${config.xdg.configHome}/nvim/config/dap.lua
          '';
        }
        {
          plugin = vimPlugins.lualine-nvim;
          config = ''
            luafile ${config.xdg.configHome}/nvim/config/statusline.lua
          '';
        }
      ];
    };
  };
}
