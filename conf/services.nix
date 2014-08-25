{ config, pkgs, ... }:

let
  expr = import ../expr { inherit pkgs; };
in {

imports = [];

services = {

  # Enable CUPS to print documents.
  printing.enable = true;

  openssh.enable = true;

  # Music Player Daemon
  mpd.enable = true;
  mpd.musicDirectory = "/data/music";

  tor.client = {
    enable = true;
    privoxy.enable = true;
    privoxy.listenAddress = "0.0.0.0:8118";
  };

  # Fixme: doesn't seem to work if tor is enabled (port clash?)
  samba = {
    enable = true;
    defaultShare.enable = true;
    defaultShare.guest = false;
    securityType = "share";
    extraConfig = ''
      workgroup = WORKGROUP
    '';
  };

  # Setup Hydra-CI
  hydra = {
    enable = true;
    package = expr.hydra;
    hydraURL = "c-cube";
    notificationSender = "benno.fuenfstueck@gmail.com";
  };
  postgresql.enable = true;
  postgresql.package = pkgs.postgresql;

};

systemd.services.shellinaboxd = {
    description = "Shellinabox daemon";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    script = "${pkgs.shellinabox}/bin/shellinaboxd";
    serviceConfig.User = "nobody";
};

networking.firewall = {
  allowPing = true;
  allowedTCPPorts = [ 80 445 139 4200 ];
  allowedUDPPorts = [ 137 138 ];
};

}