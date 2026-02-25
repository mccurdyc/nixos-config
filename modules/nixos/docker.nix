{ ... }:

{
  virtualisation.docker = {
    enable = true;
    # Prevent Docker from manipulating iptables/nftables rules. By default,
    # Docker inserts and removes firewall rules every time containers
    # start or stop. This destabilizes Tailscale's WireGuard routing
    # rules, causing SSH connections over tailscale0 to drop and
    # sometimes wedging the networking stack entirely.
    #
    # Tradeoff: Docker normally creates DOCKER-ISOLATION-STAGE-1/2
    # rules that prevent containers on different user-defined bridge
    # networks from reaching each other. With --iptables=false, that
    # isolation is gone -- containers across bridges can route to each
    # other if they know the IP. This is irrelevant unless you run
    # mutually-untrusted workloads on the same host.
    #
    # Because Docker no longer creates its own NAT rules, a static
    # masquerade rule is required for container egress. See the
    # docker-nat nftables table in networking.nix.
    extraOptions = "--iptables=false";

    autoPrune = {
      enable = true;
      dates = "weekly";
      flags = [ "--force" "--volumes" "--all" ];
    };
  };
}
