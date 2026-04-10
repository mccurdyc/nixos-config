{ ... }:

{
  programs.ripgrep = {
    enable = true;
    arguments = [
      "--hidden"
      "--glob=!.git"
    ];
  };
}
