{ config, pkgs, ... }:

let
  expr = import ../expr { inherit pkgs; };
in {

imports = [];

security.setuidPrograms = [ "dumpcap" ];

services = {

  # The locate service for finding files in the nix-store quickly.
  locate.enable = true;

  # Enable CUPS to print documents.
  printing.enable = true;

  # Add drivers to CUPS
  printing.drivers = [ expr.mfcj430w-driver ];

  # Avahi is used for finding other devices on the network.
  avahi.enable = true;
  avahi.nssmdns = true;

  # Enable dnsmasq (required to merge VPN nameservers)
  dnsmasq = {
    enable = true;
    extraConfig = ''
      bind-interfaces
      interface=lo
      no-negcache
      all-servers
      dnssec
      trust-anchor=.,19036,8,2,49AAC11D7B6F6446702E54A1607371607A1A41855200FD2CE1CDDE32F24E8FB5
      server=/vm/192.168.122.1
    '';
  };

  # HackingLab openvpn config
  openvpn.servers.hacking-lab = {
    config = ''
      ${builtins.readFile ./hacking-lab.ovpn};
      ca ${./hacking-lab-vpn.crt}
    '';
    updateResolvConf = true;
    autoStart = false;
  };

  # Enable TLP for optimal power saving
  tlp.enable = true;

  # Enable sambda for sharing files
  samba.enable = true;

};

# Use libvirtd for managing virtual machines.
# This only enables the service, but does not add users to the libvirt group.
virtualisation.libvirtd.enable = true;

# Set the default connection string for `virsh` etc to be the system qemu instance.
environment.variables.LIBVIRT_DEFAULT_URI = "qemu:///system";

# Libvirtd needs to start after data is mounted, because the storage pool lives
# on /data.
systemd.services.libvirtd = {
  after = ["data.mount"];
  requires = ["data.mount"];
};

# Enable docker for container management.
# This only enables the service, but does not add users to the docker group.
virtualisation.docker.enable = true;

# Docker images are quite big, so we don't want to place them on the SSD.
virtualisation.docker.extraOptions = "-g /data/blob/docker";
systemd.services.docker = {
  after = ["data.mount"];
  requires = ["data.mount"];
};

# We need to choose a storage driver for docker.
# "overlay2" is currently actively developed and will eventually become the default, so use it.
virtualisation.docker.storageDriver = "overlay2";

networking.firewall = {
  # Pings are very useful for network troubleshooting.
  allowPing = true;

  allowedTCPPorts = [
    3000        # hydra
    139 445     # samba
  ];

  allowedUDPPorts = [
    137 138     # samba
  ];
};

# Configure additional DNS servers
networking.extraResolvconfConf =
  let
    extraNameServers = [
      # Google IPv6 DNS servers
      "2001:4860:4860::8888"
      "2001:4860:4860::8844"
      # ipv6.lt NAT64 DNS server
      #"2001:778::37"
    ];
  in ''
    name_servers="$name_servers''${name_servers:+ }${toString extraNameServers}"
  '';
}
