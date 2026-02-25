{ ... }:

{
  # Use nftables instead of iptables for the NixOS firewall. This
  # avoids mixing iptables and nftables rule sets on the same host.
  networking.nftables.enable = true;

  # Why resolved?
  # It's the recommendation from Tailscale - https://tailscale.com/kb/1235/resolv-conf#how-do-i-stop-tailscaled-from-overwriting-etcresolvconf
  # Then, make sure in Tailscale DNS settings that "Override Local DNS" is true
  services.resolved = {
    enable = true;
    fallbackDns = [
      "1.1.1.1"
      "8.8.8.8"
      "100.100.100.100"
    ];
  };

  # Enable IP forwarding so packets from Docker bridge networks can be
  # routed to the host's external interfaces for egress.
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  };

  # Static masquerade rule for Docker container egress. Because Docker
  # is configured with --iptables=false (see docker.nix), it no longer
  # creates its own NAT/masquerade rules. Without this rule, containers
  # can reach the host but cannot reach the internet -- outbound
  # packets from the Docker bridge (172.16.0.0/12) leave the host with
  # a source address that external networks will not route back.
  # Masquerading rewrites the source to the host's outbound address so
  # return traffic finds its way back.
  networking.nftables.tables.docker-nat = {
    family = "ip";
    content = ''
      chain postrouting {
        type nat hook postrouting priority srcnat; policy accept;
        ip saddr 172.16.0.0/12 masquerade
      }
    '';
  };
}
