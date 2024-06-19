{ pkgs, ... }:

# Dont forget to run 'systemctl daemon-reload'

let
  zoekt-dir = "/home/mccurdyc/src/zoekt";
  repo-dir = "${zoekt-dir}/repos";
  index-dir = "${zoekt-dir}/index";
in
{
  systemd.timers.zoekt-mirror-github = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 07:00:00"; # daily at 7AM
      Persistent = true;
      Unit = "zoekt-mirror-github.service";
    };
  };

  systemd.services.zoekt-mirror-github = {
    path = with pkgs; [ bash "/run/wrappers" ];
    # https://www.freedesktop.org/software/systemd/man/latest/systemd.service.html#Options
    serviceConfig = {
      Type = "oneshot";
      User = "mccurdyc";
      # su -c "nix shell 'nixpkgs#git' -c git clone -c core.sshCommand='ssh -i /home/mccurdyc/.ssh/fastly_rsa.pub' --bare --verbose --progress --config zoekt.archived=0 --config zoekt.github-forks=4 --config zoekt.github-stars=13 --config zoekt.github-watchers=13 --config zoekt.name=github.com/fastly/Heavenly --config zoekt.web-url=https://github.com/fastly/Heavenly --config zoekt.web-url-type=github https://github.com/fastly/Heavenly.git /home/mccurdyc/src/zoekt/repos/github.com/fastly/Heavenly.git" mccurdyc
      # Cloning into bare repository '/home/mccurdyc/src/zoekt/repos/github.com/fastly/Heavenly.git'...
      # Load key "/home/mccurdyc/.ssh/fastly_rsa.pub": error in libcrypto
      # git@ssh.github.com: Permission denied (publickey).
      # fatal: Could not read from remote repository.
      #
      # Please make sure you have the correct access rights
      # and the repository exists.
      ExecStart = "${pkgs.zoekt}/bin/zoekt-mirror-github -org fastly -dest ${repo-dir} -token /home/mccurdyc/.github-token";
      # ExecStopPost = "systemctl restart zoekt-index.service";
    };
  };

  systemd.services.zoekt-index = {
    path = with pkgs; [ bash "/run/wrappers" ];
    # https://www.freedesktop.org/software/systemd/man/latest/systemd.service.html#Options
    serviceConfig = {
      Type = "oneshot";
      User = "mccurdyc";
      ExecStart = "${pkgs.zoekt}/bin/zoekt-git-index -index ${index-dir} ${repo-dir}/github.com/fastly/*";
      ExecStopPost = "systemctl restart zoekt-webserver.service";
    };
  };

  systemd.services.zoekt-webserver = {
    path = with pkgs; [ bash "/run/wrappers" ];
    # https://www.freedesktop.org/software/systemd/man/latest/systemd.service.html#Options
    serviceConfig = {
      Type = "oneshot";
      User = "mccurdyc";
      ExecStart = "${pkgs.zoekt}/bin/zoekt-webserver -index ${index-dir}";
    };
  };
}
