{ pkgs, ... }:

# Dont forget to run 'systemctl daemon-reload'

let
  zoekt-dir = "/home/mccurdyc/src/zoekt";
  repo-dir = "${zoekt-dir}/repos";
  index-dir = "${zoekt-dir}/index";
in
{
  systemd.user.timers.zoekt-mirror-github = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 07:00:00"; # daily at 7AM
      Persistent = true;
      Unit = "zoekt-mirror-github.service";
    };
  };

  systemd.user.services.zoekt-mirror-github = {
    path = with pkgs; [ bash "/run/wrappers" git zoekt ];
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    # https://www.freedesktop.org/software/systemd/man/latest/systemd.service.html#Options
    serviceConfig = {
      ExecStart = "bash -c 'git clone https://github.com/mccurdyc/crain.git /home/mccurdyc >/home/mccurdyc/log3.log 2>/home/mccurdyc/log4.log'";
      StandardOutput = "file:/home/mccurdyc/log1.log";
      StandardError = "file:/home/mccurdyc/log2.log";
      # ExecStart = "zoekt-mirror-github -org fastly -dest ${repo-dir} -token /home/mccurdyc/.github-token";
      # ExecStopPost = "systemctl restart zoekt-index.service";
    };
  };

  systemd.user.services.zoekt-index = {
    path = with pkgs; [ bash "/run/wrappers" zoekt ];
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    # https://www.freedesktop.org/software/systemd/man/latest/systemd.service.html#Options
    serviceConfig = {
      ExecStart = "${pkgs.zoekt}/bin/zoekt-git-index -index ${index-dir} ${repo-dir}/github.com/fastly/*";
      # ExecStopPost = "systemctl restart zoekt-webserver.service";
    };
  };

  systemd.user.services.zoekt-webserver = {
    path = with pkgs; [ bash "/run/wrappers" zoekt ];
    # https://www.freedesktop.org/software/systemd/man/latest/systemd.service.html#Options
    serviceConfig = {
      ExecStart = "zoekt-webserver -index ${index-dir}";
    };
  };
}
