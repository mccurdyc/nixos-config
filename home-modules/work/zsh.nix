{ lib, ... }:
{
  programs.zsh.initContent = lib.mkAfter ''
    eval $(keychain --eval --quiet ~/.ssh/config.d/work/fastly_rsa)
  '';
}
