{pkgs, ...}: {
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
      tn = "(){ tmux new-session -s $1 -c \"$(zshz -e $1)\" \\; split-window -v -p 25 \\; select-pane -t 1 ;}";
      dudir = "(){ sudo du -cha --max-depth=1 --exclude=/{proc,sys,dev,run} --threshold=1 $1 | sort -hr ;}";
      tmpd = ''(){ cd "$(mktemp -d -t "tmp.XXXXXXXXXX")" ;}'';
      whatsmyip = "dig +short myip.opendns.com @resolver1.opendns.com";
      curls = ''curl -o /dev/null -s -w "%{http_code}\n"'';
      ghpr = "(){ gh pr create --fill --draft $@ ;}";
      gitc = "nvim -c Neogit";
      gits = "git status";
      gitfc = ''(){ git log --format=format:"%H" | tail -1 ;}'';
      kubectl_pods_containers = ''kubectl get pods -o jsonpath='{range .items[*]}{"\n"}{.metadata.name}{": \t "}{range .spec.containers[*]}{.name}{", "}{end}{end}' | sort'';
      k = "kubectl";
    };
    history = {
      size = 2000;
      save = 2000;
      ignoreDups = true;
      ignoreSpace = true;
      # - https://zsh.sourceforge.io/Doc/Release/Options.html#History
      # 'share' basically enables 'extended' automatically.
      share = true;
      extended = true;
      # https://askubuntu.com/questions/999923/syntax-in-history-ignore
      ignorePatterns = [
        ":w"
        "cd#( *)#"
        "cp#( *)#*"
        "fg"
        "git add#( *)#*"
        "git checkout#( *)#*"
        "git clone#( *)#*"
        "git commit#( *)#*"
        "git diff#( *)#*"
        "git ll"
        "git log"
        "git pull#( *)#+"
        "git push#( *)#"
        "git show#( *)#"
        "gits"
        "kill#( *)#"
        "l[sa]#( *)#"
        "mv #( *)#"
        "nvim#( *)#"
        "pkill#( *)#"
        "rm#( *)#"
        "tn#( *)#"
        "tn#( *)#"
        "z#( *)#"
      ];
    };
    profileExtra = "";
    dotDir = ".config/zsh";
    loginExtra = "";
    initExtraFirst = ''
    '';
    initExtraBeforeCompInit = ''
      zstyle ':completion:*' menu select
    '';
    initExtra = ''
      setopt clobber
      setopt extendedglob
      setopt interactive_comments
      setopt nobeep
      setopt HIST_IGNORE_ALL_DUPS
      setopt HIST_REDUCE_BLANKS

      # NOTE: I had issues where fzf-tab wasn't including hidden files even
      # though my FZF_DEFAULT_COMMAND specifies to do so.
      # https://github.com/Aloxaf/fzf-tab/issues/193#issuecomment-784722265
      setopt globdots

      eval "$(starship init zsh)"

      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
      source ${pkgs.zsh-z}/share/zsh-z/zsh-z.plugin.zsh

      source ${pkgs.fzf}/share/fzf/completion.zsh
      # NOTE: I had issues with zsh-vi-mode overwriting ^R
      source ${pkgs.fzf}/share/fzf/key-bindings.zsh

      source <(stern --completion=zsh)
      eval "$(fastly --completion-script-zsh)"
      eval $(keychain --eval --quiet ~/.ssh/fastly_rsa)

      # https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-completion.html#cli-command-completion-path
      autoload bashcompinit && bashcompinit
      autoload -Uz compinit && compinit

      complete -C '/etc/profiles/per-user/mccurdyc/bin/aws_completer' aws
    '';
  };

  xdg.configFile."zsh/.zsh_history.default".source = ./zsh/.zsh_history.default;

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
        format = "[($profile)(\\\($region\\\))]($style)";
        style = "bold #ffe500";
      };
      gcloud = {
        symbol = "gcp:";
        format = "[(\\\($project\\\))]($style)";
        style = "bold #005aff";
      };
      golang = {
        symbol = "go:";
        format = "[$symbol($version)]($style)";
      };
      lua = {
        symbol = "lua:";
        format = "[$symbol($version)]($style)";
      };
      nix_shell = {
        symbol = "nix-shell";
        format = "[$symbol]($style)";
      };
      python = {
        symbol = "py:";
        format = "[$symbol($version)]($style)";
      };
      ruby = {
        symbol = "rb:";
        format = "[$symbol($version)]($style)";
      };
      rust = {
        symbol = "rs:";
        style = "bold #cf4910";
        format = "[$symbol($version)]($style)";
      };
      terraform = {
        symbol = "tf:";
        format = "[$symbol($version)]($style)";
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
}
