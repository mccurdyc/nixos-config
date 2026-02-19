{ ... }: {
  programs.zsh = {
    envExtra = ''
      export ANTHROPIC_DEFAULT_OPUS_MODEL="arn:aws:bedrock:us-east-2:635784355978:inference-profile/global.anthropic.claude-opus-4-6-v1"
      export ANTHROPIC_DEFAULT_SONNET_MODEL="arn:aws:bedrock:us-east-2:635784355978:inference-profile/global.anthropic.claude-sonnet-4-6"
      export ANTHROPIC_DEFAULT_HAIKU_MODEL="arn:aws:bedrock:us-east-2:635784355978:inference-profile/us.anthropic.claude-haiku-4-5-20251001-v1:0"
    '';

    shellInit = ''
      opencode() {
        aws sts get-caller-identity --profile bedrock
        if [ $? -eq 0 ]; then
            echo "SSO session is valid"
        else
            echo "refreshing SSO session"
            aws --no-browser --use-device-code sso login --profile bedrock
        fi
        AWS_PROFILE=bedrock \
        AWS_REGION=us-east-2 \
        command opencode "$@"
      }
    '';
  };
}
