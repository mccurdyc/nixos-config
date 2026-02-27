{ zshPath, ... }:

{
  # OS-login sets the login shell to bash and we can't change it.
  # exec replaces the bash process with zsh so there's no dangling
  # bash parent and `exit` behaves as expected.
  programs.bash = {
    enable = true;
    profileExtra = ''
      exec ${zshPath}
    '';
  };
}
