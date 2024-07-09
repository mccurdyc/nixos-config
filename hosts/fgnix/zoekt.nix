{ pkgs, config, ... }:

# Dont forget to run 'systemctl daemon-reload'

{
  systemd.user.services.zoekt-indexserver = {
    path = with pkgs; [ bash "/run/wrappers" git zoekt ctags ];
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    # https://www.freedesktop.org/software/systemd/man/latest/systemd.service.html#Options
    serviceConfig = {
      # https://github.com/sourcegraph/zoekt/blob/5ac92b1a7d4ab7b0dbeeaa9df77abb13d555e16b/build/builder.go#L275-L277
      ExecStart = "export CTAGS_COMMAND=ctags; zoekt-indexserver -mirror_config /home/mccurdyc/.config/zoekt/config.json -cpu_fraction 0.25 2>&1";
    };
  };

  systemd.user.services.zoekt-webserver = {
    path = with pkgs; [ bash "/run/wrappers" zoekt ];
    # https://www.freedesktop.org/software/systemd/man/latest/systemd.service.html#Options
    serviceConfig = {
      ExecStart = "zoekt-webserver -index /home/mccurdyc/zoekt-serving/index 2>&1";
    };
  };
}
