{ config, ... }: {
  programs.git = {
    enable = true;
    userName = "Colton J. McCurdy";
    userEmail = "mccurdyc22@gmail.com";
    signing = {
      key = "9CD9D30EBB7B1EEC";
      signByDefault = true;
    };
    extraConfig = {
      help = { autoCorrect = 5; }; # Run guessed command after 500ms if there is only one reasonable guess
      init = { defaultBranch = "main"; };
      core = {
        excludesfile = "${config.home.homeDirectory}/.config/git/ignore";
      };
      url = {
        # https://gist.github.com/StevenACoffman/866b06ed943394fbacb60a45db5982f2#how-to-go-get-private-repos-using-ssh-key-auth-instead-of-password-auth
        "git@github.com:" = {
          insteadOf = "https://github.com/";
        };
      };
      mergetool = {
        prompt = false;
        keepBackup = false;
      };
      merge = {
        tool = "nvimmerge";
        conflictStyle = "diff3";
      };
      mergetool."nvimmerge" = {
        # http://vimcasts.org/episodes/fugitive-vim-resolving-merge-conflicts-with-vimdiff/
        name = "nvimmerge";
        trustExitCode = true;
        cmd = "nvim -f -c Gdiffsplit! $MERGED";
      };
      diff = {
        tool = "nvimdiff";
      };
      difftool."nvimdiff" = {
        cmd = "nvim -d $LOCAL $REMOTE";
        # Be able to abort all diffs with `:cq` or `:cquit`
        trustExitCode = true;
      };
    };
    aliases = {
      l = "log --graph --topo-order --abbrev-commit --date=short --decorate --all --boundary";
      lb = "!f() { git log --graph $(git branch --show-current) --not origin/main --decorate --oneline; }; f";
      ll = "log --graph --all --decorate --oneline";
      ls = "log --pretty=format:\"%C(green)%h %C(yellow)[%ad]%Cred%d %Creset%s%Cblue [%cn]\" --decorate --date=relative";
      ld = "log --all --graph --abbrev-commit --decorate --pretty=format:\"%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n %C(white)%s%C(reset) %C(dim white)- %an%C(reset)\"";
      cleanbranches = "!f() { git branch | grep -v 'main' | xargs git branch -D; }; f";
      m = "mergetool";
      review = "!nvim -c DiffReview";
      reviews = "!nvim -c DiffReviewStaged";
    };
    delta = {
      enable = true;
      options = {
        decorations = {
          commit-decoration-style = "bold yellow box ul";
          file-decoration-style = "none";
          file-style = "bold yellow ul";
          hunk-header-decoration-style = "yellow box ul";
        };
        line-numbers = {
          line-numbers-left-style = "yellow";
          line-numbers-right-style = "yellow";
          line-numbers-minus-style = "124";
          line-numbers-plus-style = "28";
        };
        features = "decorations line-numbers";
        syntax-theme = "none";
        plus-style = ''green bold "#ccffcc"'';
        minus-style = ''red bold "#ffcccc"'';
      };
    };
    ignores = [
      ".devenv"
      ".direnv"
      "build_"
      ".aider*"
    ];
  };
}
