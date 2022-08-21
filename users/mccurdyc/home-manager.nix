{
  config,
  pkgs,
  lib,
  ...
}: let
  sources = import ../../nix/sources.nix;
  mccurdyc-base16-vim = pkgs.vimUtils.buildVimPlugin {
    name = "mccurdyc-base16-vim";
    src = pkgs.fetchFromGitHub {
      owner = "mccurdyc";
      repo = "base16-vim";
      rev = "01d8ef781a2505d5a9740783a0ea1ff623199b83";
      # nix-shell -p nix-prefetch-git --command 'nix-prefetch-git git@github.com:mccurdyc/base16-vim.git 01d8ef781a2505d5a9740783a0ea1ff623199b83'
      sha256 = "0xw7682fybz75bgfdacslsd55ycg94jc4ab29rq79h5lrzm0faxv";
    };
  };
in {
  home.username = "mccurdyc";
  home.homeDirectory = "/home/mccurdyc";

  # https://nix-community.github.io/home-manager/options.html

  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    EDITOR = "nvim";
    PAGER = "less -FirSwX";
    MANPAGER = "sh -c 'col -bx | ${pkgs.bat}/bin/bat -l man -p'";
    GPG_TTY = "$(tty)";
  };

  home.packages = with pkgs; [
    _1password
    alejandra
    bat
    docker
    fd
    fzf
    gcc
    git-crypt
    gitui
    go
    google-cloud-sdk
    gopls
    hadolint
    htop
    hugo
    jq
    ngrok
    niv
    nodejs
    pinentry-curses
    python39Packages.grip
    python3Full
    ripgrep
    starship
    subnetcalc
    tmux
    tree
    trivy
    watch
  ];

  programs = {
    ssh = {
      enable = true;
      controlMaster = "no";
      controlPath = "~/.ssh/master-%r@%n:%p";
      controlPersist = "30m";
      forwardAgent = true;

      matchBlocks = {
        "*" = {
        };

        "github.com" = {
          hostname = "ssh.github.com";
          user = "git";
          port = 443;
        };
      };
    };

    git = {
      enable = true;
      userName = "Colton J. McCurdy";
      userEmail = "mccurdyc22@gmail.com";
      signing = {
        key = "9CD9D30EBB7B1EEC";
        signByDefault = true;
      };
    };

    gitui = {
      enable = true;
    };
  };

  services.gpg-agent = {
    enable = true;
    pinentryFlavor = "curses";
    enableSshSupport = true;
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
