{ ... }:

{
  # Cap total memory available to Docker and all its containers.
  # This prevents container workloads (k3d, kind, etc.) from
  # consuming all host memory and triggering the OOM killer.
  # The limit applies to the dockerd cgroup -- any container that
  # pushes aggregate usage past this boundary will have its own
  # processes OOM-killed within the cgroup, not the host.
  systemd.services.docker.serviceConfig = {
    MemoryMax = "10G";
    MemorySwapMax = "12G";
  };
}
