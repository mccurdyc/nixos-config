{ ... }: {
  programs.zsh.shellInit = ''
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
      ANTHROPIC_MODEL="arn:aws:bedrock:us-east-2:635784355978:inference-profile/us.anthropic.claude-sonnet-4-5-20250929-v1:0" \
      ANTHROPIC_SMALL_FAST_MODEL="arn:aws:bedrock:us-east-2:635784355978:inference-profile/us.anthropic.claude-3-5-haiku-20241022-v1:0" \
      command opencode "$@"
    }
  '';
}
