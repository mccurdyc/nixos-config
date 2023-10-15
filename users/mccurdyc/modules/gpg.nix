{darwin, ...}:
{
  programs.gpg = {
    enable = true;
  };
}
// (
  if darwin
  then {}
  else {
    services.gpg-agent = {
      enable = true;
    };
  }
)
