{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    awscli2
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

    (writeShellScriptBin "jira" ''
      JIRA_API_TOKEN=$(cat ~/.atlassian-api-token) \
      JIRA_USERNAME=$(cat ~/.atlassian-email) \
      JIRA_URL=https://fastly.atlassian.net \
      exec ${jira-cli-go}/bin/jira "$@"
    '')

    (writeShellScriptBin "claude" ''
      aws sts get-caller-identity --profile bedrock > /dev/null 2>&1
      if [ $? -ne 0 ]; then
        echo "refreshing SSO session"
        aws --no-browser --use-device-code sso login --profile bedrock
      fi
      AWS_PROFILE=bedrock \
      AWS_REGION=us-east-2 \
      exec ${claude-code}/bin/claude "$@"
    '')

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

    (writeShellScriptBin "pi" ''
      aws sts get-caller-identity --profile bedrock > /dev/null 2>&1
      if [ $? -ne 0 ]; then
        echo "refreshing SSO session"
        aws --no-browser --use-device-code sso login --profile bedrock
      fi
      AWS_PROFILE=bedrock \
      AWS_REGION=us-east-2 \
      exec ${pi-coding-agent}/bin/pi "$@"
    '')
  ]
  ++ lib.optional stdenv.isLinux cntr;
}
