{ config, pkgs, ... }:

let
  expr = import ../expr { inherit pkgs; };
in {

imports = [];

services = {

  # Enable CUPS to print documents.
  printing.enable = true;

  # Music Player Daemon
  mpd.enable = true;
  mpd.musicDirectory = "/data/music";

#  tor.client = {
#    enable = true;
#    privoxy.enable = true;
#    privoxy.listenAddress = "0.0.0.0:8118";
#  };

  # Fixme: doesn't seem to work if tor is enabled (port clash?)
  # Hmm, Doesn't seem to work reliably at all
  samba = {
    enable = true;
    securityType = "share";
    extraConfig = ''
      [global]
      workgroup = WORKGROUP
    '';
  };

  # Setup Hydra-CI
  hydra = {
#    enable = true;
    package = expr.hydra;
    hydraURL = "c-cube";
    notificationSender = "benno.fuenfstueck@gmail.com";
  };
  postgresql.enable = true;
  postgresql.package = pkgs.postgresql;

  avahi.enable = true;

};

virtualisation.libvirtd.enable = true;

networking.firewall = {
  allowPing = true;
  allowedTCPPorts = [
    135 139 445 # smbd
    3000        # hydra
  ];
  allowedUDPPorts = [
    137 138 139 # nmbd
  ];

  # We need to disable reverse path test because libvirt networking fails with it.
  # Setup our own reverse path test that ignores libvirt virtual interfaces
  checkReversePath = false;
  extraCommands = ''
    ip46tables -A PREROUTING -t raw ! -i virbr+ -m rpfilter --invert -j DROP
  '';
  extraStopCommands = ''
    ip46tables -D PREROUTING -t raw ! -i virbr+ -m rpfilter --invert -j DROP
  '';
};

}
