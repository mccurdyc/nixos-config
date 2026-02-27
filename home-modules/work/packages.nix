{ pkgs, ... }:

{
  home.packages = with pkgs; [
    awscli2
    cntr
    google-cloud-sdk
    infra
    k3d
    k9s
    kubectl
    kubernetes-helm
    kubie
    ssm-session-manager-plugin
    wireguard-tools
    zoekt

    (writeShellScriptBin "opencode" ''
      aws sts get-caller-identity --profile bedrock > /dev/null 2>&1
      if [ $? -ne 0 ]; then
        echo "refreshing SSO session"
        aws --no-browser --use-device-code sso login --profile bedrock
      fi
      AWS_PROFILE=bedrock \
      AWS_REGION=us-east-2 \
      exec ${opencode}/bin/opencode "$@"
    '')
  ];
}
