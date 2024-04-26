{ ... }:

{
  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.useDaemon = true;
  nix.gc.user = "root";

  nix.settings = {
    # Why?
    # https://nixcademy.com/2024/03/08/running-nixos-integration-tests-on-macos/
    # https://nixos.org/manual/nix/stable/command-ref/conf-file#conf-system-features
    # Confirm with - 'nix show-config system-features'
    # Automatically detected on nix 2.19
    system-features = "nixos-test apple-virt";

    # https://nixcademy.com/2024/02/12/macos-linux-builder/
    trusted-users = [
      "@admin" # @admin means all users in the wheel group.
    ];
  };
}
