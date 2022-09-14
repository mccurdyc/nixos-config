# https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake.html#flake-references
{
  # inputs: An attrset specifying the dependencies of the flake (described below).
  # https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake.html#flake-inputs
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-22.05";
    # We use the unstable nixpkgs repo for some packages.
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-22.05";
      # We want home-manager to use the same set of nixpkgs as our system.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    base16-vim-mccurdyc = {
      url = "github:mccurdyc/base16-vim";
      flake = false;
    };

    vim-surround = {
      url = "github:tpope/vim-surround";
      flake = false;
    };

    vim-unimpaired = {
      url = "github:tpope/vim-unimpaired";
      flake = false;
    };

    vim-fugitive = {
      url = "github:tpope/vim-fugitive";
      flake = false;
    };

    tcomment_vim = {
      url = "github:tomtom/tcomment_vim";
      flake = false;
    };

    plenary-nvim = {
      url = "github:nvim-lua/plenary.nvim";
      flake = false;
    };

    telescope-fzf-native-nvim = {
      url = "github:nvim-telescope/telescope-fzf-native.nvim";
      flake = false;
    };

    telescope-dap-nvim = {
      url = "github:nvim-telescope/telescope-dap.nvim";
      flake = false;
    };

    vim-gh-line = {
      url = "github:ruanyl/vim-gh-line";
      flake = false;
    };

    vim-go = {
      url = "github:fatih/vim-go";
      flake = false;
    };

    rust-vim = {
      url = "github:rust-lang/rust.vim";
      flake = false;
    };

    nvim-dap-ui = {
      url = "github:rcarriga/nvim-dap-ui";
      flake = false;
    };

    nvim-web-devicons = {
      url = "github:kyazdani42/nvim-web-devicons";
      flake = false;
    };

    nvim-tree-lua = {
      url = "github:kyazdani42/nvim-tree.lua";
      flake = false;
    };

    coq_nvim = {
      url = "github:ms-jpq/coq_nvim";
      flake = false;
    };

    nvim-bqf = {
      url = "github:kevinhwang91/nvim-bqf";
      flake = false;
    };

    formatter-nvim = {
      url = "github:mhartington/formatter.nvim";
      flake = false;
    };

    telescope-nvim = {
      url = "github:nvim-telescope/telescope.nvim";
      flake = false;
    };

    nvim-lspconfig = {
      url = "github:neovim/nvim-lspconfig";
      flake = false;
    };

    # TODO: replace with null-ls. deprecated.
    nvim-ale-diagnostic = {
      url = "github:nathanmsmith/nvim-ale-diagnostic";
      flake = false;
    };

    gitsigns-nvim = {
      url = "github:lewis6991/gitsigns.nvim";
      flake = false;
    };

    neogit = {
      url = "github:TimUntersberger/neogit";
      flake = false;
    };

    vim-terraform = {
      url = "github:hashivim/vim-terraform";
      flake = false;
    };

    nvim-treesitter = {
      url = "github:nvim-treesitter/nvim-treesitter";
      flake = false;
    };

    nvim-ts-rainbow = {
      url = "github:p00f/nvim-ts-rainbow";
      flake = false;
    };

    nvim-dap = {
      url = "github:mfussenegger/nvim-dap";
      flake = false;
    };

    lualine-nvim = {
      url = "github:nvim-lualine/lualine.nvim";
      flake = false;
    };
  };

  # outputs: A function that, given an attribute set containing the outputs of each
  # of the input flakes keyed by their identifier, yields the Nix values provided
  # by this flake. Thus, in the example above, inputs.nixpkgs contains the result
  # of the call to the outputs function of the nixpkgs flake
  #
  # The value returned by the outputs function must be an attribute set.
  # The attributes can have arbitrary values; however, various nix subcommands
  # require specific attributes to have a specific value (e.g. packages.x86_64-linux
  # must be an attribute set of derivations built for the x86_64-linux platform).
  #
  # Each input is fetched, evaluated and passed to the outputs function as a set
  # of attributes with the same name as the corresponding input.
  #
  # The special input named self refers to the outputs and source tree of this flake.
  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
    # https://nixos.org/manual/nix/stable/language/constructs.html#functions
    # An @-pattern provides a means of referring to the whole value being matched
  } @ inputs: let
    system = "x86_64-linux"; #current system
    pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
    lib = nixpkgs.lib;

    vimPlugins = {
      inherit (inputs) base16-vim-mccurdyc;
    };

    mkSystem = pkgs: system: hostname:
      pkgs.lib.nixosSystem {
        system = system;
        # replaces the older configuration.nix
        modules = [
          {networking.hostName = hostname;}
          # General configuration (users, networking, sound, etc)
          ./modules/system/configuration.nix
          # Hardware config (bootloader, kernel modules, filesystems, etc)
          (./. + "/hosts/${hostname}/hardware-configuration.nix")
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useUserPackages = true;
              useGlobalPkgs = true;
              extraSpecialArgs = {inherit inputs;};
              users.mccurdyc = ./. + "/hosts/${hostname}/user.nix";
            };
          }
          {
            nixpkgs.overlays = [
              (import ./overlays/vim-plugins.nix nixpkgs vimPlugins system)
            ];
          }
        ];
        specialArgs = {inherit inputs;};
      };
  in {
    nixosConfigurations = {
      nuc = mkSystem inputs.nixpkgs "x86_64-linux" "nuc";
    };
  };
}
