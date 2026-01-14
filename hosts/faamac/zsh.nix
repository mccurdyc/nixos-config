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
      AWS_PROFILE=bedrock AWS_REGION=us-west-2 command opencode --model amazon-bedrock/anthropic.claude-sonnet-4-5-20250929-v1:0 "$@"
    }
  '';
}
