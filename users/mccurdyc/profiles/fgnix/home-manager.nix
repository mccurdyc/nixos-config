{ config, pkgs }: {
  config.modules.packages = {
    enable = true;
    additionalPackages = with pkgs; [
      awscli2
      infra
      kubectl
      kubernetes-helm
      kubie
      python311Packages.google-compute-engine # needed for GCE startup-scripts
      ruby_3_1
      ssm-session-manager-plugin
      terraform-docs
      terraform-ls
      tflint
      wireguard-tools
    ];
  };
}
