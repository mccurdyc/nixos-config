{ config, pkgs, ... }: {
  config.modules.packages = {
    enable = true;
    additionalPackages = with pkgs; [
      awscli2
      google-cloud-sdk
      infra
      k6
      kubectl
      kubernetes-helm
      kubie
      ruby_3_1
      ssm-session-manager-plugin
      terraform-docs
      terraform-ls
      tflint
      wireguard-tools
    ];
  };
}
