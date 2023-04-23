{ pkgs
, lib
, config
, ...
}:
with lib; let
  cfg = config.modules.zsh;
in
{
  options.modules.zsh = { enable = mkEnableOption "zsh"; };
  config = mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      defaultKeymap = "viins";
      enableCompletion = true;
      enableAutosuggestions = true;
      enableSyntaxHighlighting = true;
      shellAliases = {
        tree = "tree --dirsfirst --noreport -ACF";
        grep = "grep --color=auto --exclude=tags --exclude-dir=.git";
        tl = "tmux list-sessions";
        ta = "tmux attach -t ";
        tn = "(){ tmux new-session -s $1 -c $(zshz -e $1) \\; split-window -v -p 25 \\; select-pane -t 1 ;}";
        dudir = "(){ sudo du -cha --max-depth=1 --exclude=/{proc,sys,dev,run} --threshold=1 $1 | sort -hr ;}";
        tmpd = ''(){ cd "$(mktemp -d -t "tmp.XXXXXXXXXX")" ;}'';
        whatsmyip = "dig +short myip.opendns.com @resolver1.opendns.com";
        ghpr = "(){ gh pr create --fill --draft $@ ;}";
        gitc = "nvim -c Neogit";
        gits = "git status";
        gitfc = ''(){ git log --format=format:"%H" | tail -1 ;}'';
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

        export FASTLY_CHEF_USERNAME="cmccurdy"
      '';
      sessionVariables = { };
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

        eval "$(direnv hook zsh)"
        eval "$(starship init zsh)"

        source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
        source ${pkgs.zsh-z}/share/zsh-z/zsh-z.plugin.zsh

        source ${pkgs.fzf}/share/fzf/completion.zsh
        # NOTE: I had issues with zsh-vi-mode overwriting ^R
        source ${pkgs.fzf}/share/fzf/key-bindings.zsh

        eval $(keychain --eval --quiet ~/.ssh/fastly_rsa)
      '';
    };

    programs.starship = {
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

        memory_usage = {
          symbol = "mem:";
          format = "|[$symbol($version )]($style)";
        };
        docker_context = {
          symbol = "docker:";
          format = "|[$symbol($version )]($style)";
        };
        golang = {
          symbol = "go:";
          format = "|[$symbol($version )]($style)";
        };
        lua = {
          symbol = "lua:";
          format = "|[$symbol($version )]($style)";
        };
        nix_shell = {
          symbol = "nix:";
          format = "|[$symbol($version )]($style)";
        };
        nodejs = {
          symbol = "nodejs:";
          format = "|[$symbol($version )]($style)";
        };
        package = {
          symbol = "pkg:";
          format = "|[$symbol($version )]($style)";
        };
        python = {
          symbol = "py:";
          format = "|[$symbol($version )]($style)";
        };
        ruby = {
          symbol = "rb:";
          format = "|[$symbol($version )]($style)";
        };
        rust = {
          symbol = "rs:";
          format = "|[$symbol($version )]($style)";
        };
        terraform = {
          symbol = "tf:";
          format = "|[$symbol($version )]($style)";
        };
        sudo.symbol = "sudo:";
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
  };
}
