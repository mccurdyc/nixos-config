{ lib, ... }:
{
  # Fetch rarely-changing secrets from 1Password at activation time (not shell
  # init) so zsh startup stays fast. Re-run `darwin-rebuild switch` to refresh.
  # Requires an authenticated `op` session (touch 1Password if prompted).
  home.activation.opSecrets = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if command -v op >/dev/null 2>&1 && op whoami >/dev/null 2>&1; then
      op item get 'openrouter' --fields label=api_key --reveal > $HOME/.openrouter-api-key
      chmod 600 $HOME/.openrouter-api-key
    else
      echo "warning: skipping 1Password secret fetch (op unavailable or not signed in)" >&2
    fi
  '';

  # The file contains only the key value; export it for tools like pi.
  programs.zsh.initContent = lib.mkAfter ''
    [ -f "$HOME/.openrouter-api-key" ] && export OPENROUTER_API_KEY="$(cat "$HOME/.openrouter-api-key")"
  '';
}
