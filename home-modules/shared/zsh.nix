{ pkgs, lib, ... }: {

  programs.zsh = {
    enable = true;
    defaultKeymap = "viins";
    enableCompletion = true;
    autosuggestion.enable = false; # This breaks FZF_CTRL_T_COMMAND
    syntaxHighlighting.enable = true;
    shellAliases = {
      assm = ''() {
      aws sts get-caller-identity --profile $1; \
      if [ $? -eq 0 ]; then \
          echo "SSO session is valid"; \
      else \
          echo "refreshing SSO session"; \
          aws --no-browser sso login --profile $1; \
      fi; \
      aws ssm start-session \
        --profile $1 \
        --region $2 \
        --target "$(aws ec2 describe-instances \
          --profile $1 \
          --region $2 \
          --output text \
          --query 'Reservations[].Instances[?State.Name==`running`].[InstanceId,Tags[?Key==`Name`].Value | [0]]' |\
          fzf --query $3 |\
          awk '{print $1}' \
        )";
      }'';
      tl = "tmux list-sessions";
      ta = "tmux attach -t ";
      # https://www.perplexity.ai/search/tmux-newsession-but-gv__phO6TVuT6dxY.15Nrw#1
      tn = "(){ tmux new-session -s $1 \\; send-keys \"__zoxide_z $1\" Enter \\; split-window -v -l 12 \\; send-keys \"__zoxide_z $1\" Enter \\; select-pane -t 0; }";
      zn = "(){ (zellij delete-session $1 || true) && zellij --session $1 options --default-cwd $(zoxide query $1) --default-layout ~/.config/zellij/layouts/main.kdl; }";
      zl = "(){ zellij list-sessions; }";
      za = "() {zellij attach $1; }";
      grep = "grep --color=auto --exclude=tags --exclude-dir=.git";
      dudir = "(){ sudo du -cha --max-depth=1 --exclude=/{proc,sys,dev,run} --threshold=1 $1 | sort -hr ;}";
      tmpd = ''(){ cd "$(mktemp -d -t "tmp.XXXXXXXXXX")" ;}'';
      whatsmyip = "dig +short myip.opendns.com @resolver1.opendns.com";
      curls = ''curl -o /dev/null -s -w "%{http_code}\n"'';
      ghpr = "(){ gh pr create --fill --draft $@ ;}";
      gits = "git status";
      g = ''nvim -c Neogit'';
      gr = ''nvim -c DiffReview'';
      grs = ''nvim -c DiffReviewStaged'';
      gitfc = ''(){ git log --format = format: "%H" | tail - 1; }'';
      kubectl_pods_containers = ''kubectl get pods -o jsonpath='{ range .items[*]}{"\n"}{.metadata.name}{": \t "}{range .spec.containers[*]}{.name}{", "}{end}{end}' | sort'';
      docker_ps = ''docker ps --format "{{.Names}}\t{{.Ports}}\t{{.Status}}"'';
      k = "kubectl";
      zkt = "zoekt -index_dir $HOME/zoekt-serving/index -r";
      zobs = "zoekt -index_dir $HOME/zoekt-serving/index \"r:obsidian.md $@\"";
      stopwatch = ''
        start=$(date +%s)
        if [[ $1 == ?([+-])+([0-9]) ]]; then
         ((start += $1))
        elif [[ $1 ]]; then
         echo "invalid argument '$1': ignoring it"
        fi

        while true; do
         now=$(date +%s)
         days=$(( (now - start) / 86400 ))
         seconds=$(( (now - start) % 86400 ))
         printf "\r%d day(s) and %s " $days $(date --utc --date @$seconds +%T)
         sleep 0.1
        done
      '';
    };

    envExtra = ''
      export ZELLIJ_AUTO_ATTACH=false
      export ZELLIJ_AUTO_EXIT=true
      export CTAGS_COMMAND=ctags # zoekt - https://github.com/sourcegraph/zoekt/blob/5ac92b1a7d4ab7b0dbeeaa9df77abb13d555e16b/doc/ctags.md?plain=1#L18-L21
      # https://minsw.github.io/fzf-color-picker/
      export FZF_DEFAULT_OPTS='--color=fg:#9e9e9e,bg:#040405,hl: --color=fg+:#e4e4e4,bg+:#262626,hl+:#ffa500 --color=info:#9e9e9e,prompt:#ffa500,pointer:#ffa500 --color=marker:#ff5f5f,spinner:#ffa500,header:#ffa500'
      export CODELLDB_PATH="${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb"
    '';

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
        ":wq"
        "cd#( *)#"
        "cp#( *)#*"
        "fg"
        "git init#( *)#*"
        "git add#( *)#*"
        "git checkout#( *)#*"
        "git clone#( *)#*"
        "git clean#( *)#*"
        "git commit#( *)#*"
        "git diff#( *)#*"
        "git ll"
        "git log"
        "git pull#( *)#*"
        "git push#( *)#"
        "git show#( *)#"
        "gits"
        "kill#( *)#"
        "l[sa]#( *)#*"
        "mv #( *)#"
        "nvim#( *)#*"
        "mkdir#( *)#*"
        "which#( *)#*"
        "touch#( *)#*"
        "pkill#( *)#"
        "rm#( *)#"
        "tmux"
        "tl"
        "z#( *)#"
      ];
    };
    profileExtra = "";
    dotDir = ".config/zsh";
    loginExtra = ''
      # This has to come after where FZF_DEFAULT_OPTS is set
      # Remember that fzf-tab doesn't follow FZF_DEFAULT_OPTS by default. If you want it to use your default fzf options, you can set:
      zstyle ':fzf-tab:*' use-fzf-default-opts yes
    '';
    initContent = lib.mkOrder 550 ''
      zstyle ':completion:*' menu select

      # https://vninja.net/2024/12/28/ghostty-workaround-for-missing-or-unsuitable-terminal-xterm-ghostty/
      if [[ "$TERM_PROGRAM" == "ghostty" ]]; then
        export TERM=xterm-256color
      fi

      setopt clobber
      setopt extendedglob
      setopt interactive_comments
      setopt nobeep
      setopt HIST_IGNORE_ALL_DUPS
      setopt HIST_REDUCE_BLANKS

      typeset -A ZSH_HIGHLIGHT_STYLES
      ZSH_HIGHLIGHT_STYLES[comment]='fg=251' # grey

      # NOTE: I had issues where fzf-tab wasn't including hidden files even
      # though my FZF_DEFAULT_COMMAND specifies to do so.
      # https://github.com/Aloxaf/fzf-tab/issues/193#issuecomment-784722265
      setopt globdots

      eval "$(starship init zsh)"
      eval "$(just --completions zsh)"

      source ${pkgs.fzf}/share/fzf/completion.zsh
      # NOTE: I had issues with zsh-vi-mode overwriting ^R
      source ${pkgs.fzf}/share/fzf/key-bindings.zsh

      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
      source ${pkgs.zsh-fzf-history-search}/share/zsh-fzf-history-search/zsh-fzf-history-search.plugin.zsh

      if [ -x "$(command -v stern)" ]; then
        source <(stern --completion=zsh)
      fi

      if [ -x "$(command -v fastly)" ]; then
        eval "$(fastly --completion-script-zsh)"
      fi

      if [ -x "$(command -v dagger)" ]; then
        source <(dagger completion zsh)
      fi

      if [ -x "$(command -v k3d)" ]; then
        source <(k3d completion zsh)
      fi

      eval $(keychain --eval --quiet ~/.ssh/config.d/work/fastly_rsa)

      # https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-completion.html#cli-command-completion-path
      autoload bashcompinit && bashcompinit
      autoload -Uz compinit && compinit

      complete -C "${pkgs.awscli2}/bin/aws_completer" aws

      eval "$(zoxide init zsh)"
    '';
  };

  xdg.configFile."zsh/.zsh_history.default".source = ./zsh/.zsh_history.default;

  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      package.disabled = true;
      format = "\\\[$username[@](bold #5fd787)$hostname\\\] \\\[$directory\\\] (\\\[($git_state )($git_status)($git_branch)($git_commit)\\\])($sudo)($golang)($helm)($lua)($nodejs)($ruby)($rust)($terraform)( \\\[$jobs\\\])( \\\[$status\\\])( \\\[$shell\\\])$line_break$time $character";

      character = {
        success_symbol = "[%%](bold #5fd787)";
        error_symbol = "[%%](bold #ff5f5f)";
        vicmd_symbol = "[V](bold #5fd787)";
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
        style_root = "bold #ff5f5f";
      };

      hostname = {
        ssh_only = false;
        disabled = false;
        format = "[$hostname]($style)";
        style = "bold white";
      };

      directory = {
        read_only = ":ro";
        format = "[$path](bold #ffa500)[$read_only](bold #ff5f5f)";
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
        style = "bold #5fd787";
      };

      git_commit = {
        format = "[\\($hash$tag\\)]($style)";
        style = "bold white";
      };

      # kubernetes = {
      #   symbol = "k8s:";
      #   disabled = false;
      #   format = "[$symbol$context( \($namespace\))]($style)";
      # };

      aws = {
        symbol = "aws:";
        format = "[($profile)(\\\($region\\\))]($style)";
        style = "bold #ffe500";
      };
      gcloud = {
        symbol = "gcp:";
        format = "[(\\\($project\\\))]($style)";
        style = "bold #2950c5";
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
