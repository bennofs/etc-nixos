{ config, pkgs, ... }:

let
  expr = import ../expr { inherit pkgs; };
in {

imports = [];

services = {

  # The locate service for finding files in the nix-store quickly.
  locate.enable = true;

  # Enable CUPS to print documents.
  printing.enable = true;

  # Avahi is used for finding other devices on the network.
  avahi.enable = true;

};

# Use libvirtd for managing virtual machines.
# This only enables the services, but does not users to the libvirt group.
virtualisation.libvirtd.enable = true;

# Enable docker for container management.
# This only enables the service, but does not add users to the docker group.
virtualisation.docker.enable = true;

# We need to choose a storage driver for docker.
# "overlay" is currently actively developed and will eventually become the default, so use it.
virtualisation.docker.storageDriver = "overlay";

networking.firewall = {
  # Pings are very useful for network troubleshooting.
  allowPing = true;

  allowedTCPPorts = [
    3000        # hydra
  ];

  # We want to route packets coming from VMs, so we need to disable the
  # reverse path test for the libvirt bridge interfaces.
  checkReversePath = false;

  # Setup a restricted reverse path test that doesn't apply to libvirt's bridge interfaces.
  extraCommands = ''
    ip46tables -A PREROUTING -t raw ! -i virbr+ -m rpfilter --invert -j DROP
  '';

  # When stopping the firewall, remove the restricted reverse path test again.
  extraStopCommands = ''
    ip46tables -D PREROUTING -t raw ! -i virbr+ -m rpfilter --invert -j DROP
  '';
};

}
