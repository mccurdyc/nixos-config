{
  config,
  pkgs,
  ...
}: {
  config.modules.packages = {
    enable = true;
    additionalPackages = with pkgs; [
      awscli2
      infra
      kubectl
      kubernetes-helm
      kubie
      ssm-session-manager-plugin
    ];
  };
}
