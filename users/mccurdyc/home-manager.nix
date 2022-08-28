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
    zsh-fzf-tab
    zsh-z
  ];

  programs = {
    zsh = {
      enable = true;
      defaultKeymap = "viins";
      enableCompletion = true;
      enableAutosuggestions = true;
      enableSyntaxHighlighting = true;
      shellAliases = {
        diff = "diff -u";
        tree = "tree --dirsfirst --noreport -ACF";
        grep = "grep --color=auto --exclude=tags --exclude-dir=.git";
        tl = "tmux list-sessions";
        ta = "tmux attach -t ";
        tn = "(){ tmux new-session -s $1 \\; split-window -v -p 15 \\; select-pane -t 1 ;}";
        dudir = "(){ sudo du -cha --max-depth=1 --exclude=/{proc,sys,dev,run} --threshold=1 $1 | sort -hr ;}";
        cdld = ''(){ if [ -f ~/.last_dir ]; then; cd "`cat ~/.last_dir`"; fi ;}'';
        cd = ''(){ builtin cd $@; pwd > ~/.last_dir ;}'';
        tmpd = ''(){ cd "$(mktemp -d -t "tmp.XXXXXXXXXX")" ;}'';
        whatsmyip = "dig +short myip.opendns.com @resolver1.opendns.com";
        ghpr = "(){ gh pr create --fill --draft $@ ;}";
        gitc = "nvim -c Neogit";
        gits = "git status";
        gitfc = ''(){ git log --format=format:"%H" | tail -1 ;}'';
        gp = "git push";
        kubectl_pods_containers = ''kubectl get pods -o jsonpath='{range .items[*]}{"\n"}{.metadata.name}{":\t"}{range .spec.containers[*]}{.name}{", "}{end}{end}' | sort'';
      };
      history = {
        size = 10000;
        save = 10000;
        ignoreDups = true;
        ignoreSpace = true;
        ignorePatterns = [
          "rm *"
          "pkill *"
        ];
      };
      profileExtra = "";
      dotDir = ".config/zsh";
      envExtra = ''
        # For commit signing on the iPad
        export GPG_TTY=$(tty)

        export EDITOR="$(which nvim)"
        export TERMINAL="$(which alacritty)"
        export BROWSER="$(which firefox)"

        export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude vendor --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"
      '';
      sessionVariables = {};
      loginExtra = "";
      initExtraFirst = ''
      '';
      initExtraBeforeCompInit = ''
        zstyle ':completion:*' menu select
      '';
      initExtra = ''
        setopt HIST_IGNORE_ALL_DUPS
        setopt HIST_FIND_NO_DUPS
        setopt HIST_IGNORE_SPACE
        setopt clobber
        setopt extendedglob
        setopt inc_append_history
        setopt interactive_comments
        setopt nobeep

        eval "$(starship init zsh)"

        source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
        source ${pkgs.zsh-z}/share/zsh-z/zsh-z.plugin.zsh

        source ${pkgs.fzf}/share/fzf/completion.zsh
        # NOTE: I had issues with zsh-vi-mode overwriting ^R
        source ${pkgs.fzf}/share/fzf/key-bindings.zsh
      '';
    };

    starship = {
      enable = true;
      settings = {
        add_newline = true;
        package.disabled = true;
        format = "\\\[$username[@](bold #00ffa5)$hostname\\\] \\\[$directory\\\] (\\\[($git_state )($git_status)($git_branch)($git_commit)\\\])( \\\[($aws)($gcloud)\\\])( \\\[($nix_shell)($memory_usage)($env_var)($custom)($sudo)\\\])( \\\[($kubernetes)($docker_context)($package)($golang)($helm)($lua)($nodejs)($ruby)($rust)($terraform)($buf)\\\])( \\\[$cmd_duration\\\])( \\\[$jobs\\\])( \\\[$status\\\])( \\\[$shell\\\])$line_break$time $character";

        character = {
          success_symbol = "[%%](bold #00ffa5)";
          error_symbol = "[%%](bold #ff005a)";
          vicmd_symbol = "[V](bold #00ffa5)";
        };

        time = {
          disabled = false;
          format = "[$time]($style)";
          style = "bold white";
          use_12hr = false;
        };

        username = {
          show_always = true;
          format = "[$user]($style)";
          style_user = "bold #ffa500";
          style_root = "bold #ff005a";
        };

        hostname = {
          ssh_only = true;
          disabled = false;
          format = "[$hostname]($style)";
          style = "bold white";
        };

        directory = {
          read_only = ":ro";
          format = "[$path](bold #ffa500)[$read_only](bold #ff005a)";
        };

        git_status = {
          ahead = "=>";
          behind = "<=";
          diverged = "<=>";
          renamed = "r";
          deleted = "x";
        };

        git_branch = {
          symbol = "";
          format = "[$symbol$branch(:$remote_branch)]($style)";
          style = "bold #00ffa5";
        };

        git_commit = {
          format = "[\\($hash$tag\\)]($style)";
          style = "bold white";
        };

        kubernetes = {
          symbol = "k8s:";
          disabled = false;
          format = "[$symbol$context( \($namespace\))]($style)";
        };

        aws = {
          symbol = "aws:";
          format = "[($profile )(\\\($region\\\) )(\\\[$duration\\\] )]($style)";
          style = "bold #ffe500";
        };

        gcloud = {
          symbol = "gcp:";
          format = "[(\\\($project\\\))]($style)";
          style = "bold #005aff";
        };

        docker_context.symbol = "docker:";
        golang.symbol = "go:";
        lua.symbol = "lua:";
        memory_usage.symbol = "mem:";
        nix_shell.symbol = "nix:";
        nodejs.symbol = "nodejs:";
        package.symbol = "pkg:";
        python.symbol = "py:";
        ruby.symbol = "rb:";
        rust.symbol = "rs:";
        sudo.symbol = "sudo:";
        terraform.symbol = "tf:";
        cmd_duration = {
          min_time = 2000;
          format = "took [$duration]($style)";
          style = "bold yellow";
        };
        jobs = {
          symbol = "!!!";
          format = "[$symbol( $number)]($style)";
        };
      };
    };

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
