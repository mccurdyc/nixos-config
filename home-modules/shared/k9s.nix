{ ... }:
{
  programs.k9s = {
    enable = true;
    views = {
      "v1/pods" = {
        columns = [
          "NAME"
          "NAMESPACE"
          "STATUS"
          "READY"
          "RESTARTS"
          "AGE"
          "IP"
          "NODE"
          "CPU"
          "MEM"
        ];
      };
    };
  };
}
