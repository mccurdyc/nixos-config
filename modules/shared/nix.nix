{ pkgs, user, ... }:

{
  nix = {
    package = pkgs.nix;
    optimise.automatic = true;

    gc = {
      automatic = true;
      options = "--delete-older-than 1w";
    };

    settings = {
      sandbox = "relaxed";

      allowed-users = [ user ];
      trusted-users = [ "root" user ];

      # https://nixcademy.com/2024/02/12/macos-linux-builder/
      extra-trusted-users = [ user ];

      substituters = [
        "https://union.cachix.org/"
        "https://nix-community.cachix.org/"
        "https://helix.cachix.org/"
      ];

      trusted-public-keys = [
        "union.cachix.org-1:TV9o8jexzNVbM1VNBOq9fu8NK+hL6ZhOyOh0quATy+M="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
      ];

      experimental-features = [ "nix-command" "flakes" ];
    };

    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';
  };
}
