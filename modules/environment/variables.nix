{
  EDITOR = "nvim";
  VISUAL = "nvim";
  TERM = "screen-256color";

  BROWSER = "firefox";
  DOCKER_DEFAULT_PLATFORM = "linux/amd64";

  FZF_DEFAULT_COMMAND = "fd --type f --hidden --exclude vendor --exclude .git";
  FZF_CTRL_T_COMMAND = "$FZF_DEFAULT_COMMAND";
  FZF_ALT_C_OPTS = "--preview 'tree -C {} | head -200'";

  FASTLY_CHEF_USERNAME = "cmccurdy";
  INFRA_SKIP_VERSION_CHECK = "true";

  # https://docs.github.com/en/authentication/managing-commit-signature-verification/telling-git-about-your-signing-key#telling-git-about-your-gpg-key
  GPG_TTY = "$(tty)";
}
