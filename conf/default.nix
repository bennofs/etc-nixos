{ config, pkgs, expr, ... }:

with builtins; with pkgs.lib; {

imports = [
  ./desktop.nix
  ./services.nix
  ./accounts.nix
];

# Available packages
environment.systemPackages = with pkgs;
  [ # Version control / archiving
    git mercurial bazaar subversion unzip wget zip unrar gitAndTools.hub

    # Linux utils
    pmutils psmisc htop fuse inetutils which binutils linuxPackages.perf bc

    # Desktop utils
    xlibs.xmodmap scrot xsel xlibs.xbacklight arandr

    # Command line utils 
    k2pdfopt ncmpcpp mpc_cli beets manpages man wpa_supplicant dtrx mp3gain

    # Development tools
    nix-repl llvm coq haskellPackages.ghc

    # Desktop applications
    xfce.thunar gimp hipchat skype wireshark libreoffice calibre conkerorWrapperWithoutScrollbars
    keepassx2 zathura rxvt_unicode firefox chromium

    # Other
    expr.softwarechallenge16-gui expr.armagetronad
  ];

boot.cleanTmpDir = true;
boot.kernel.sysctl = {
  "kernel.dmesg_restrict" = true;
};
hardware.pulseaudio.enable = true;

services.udev.packages = with pkgs; [
  # Enable Android udev rules
  # This is needed so that the android device nodes in /dev have
  # the correct access levels (they will be managed by systemd-logind)
  libmtp
];
services.udev.extraRules = ''
  # AREXX USB-IR-Transceiver. For flashing ASURO robot
  SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", ENV{ID_REMOTE_CONTROL}="1"
'';

fileSystems."/data" = {
  label = "data";
  fsType = "ext4";
};

# Environment variables
environment.variables = {
  BROWSER = builtins.toString (pkgs.writeScript "run-browser.sh" ''
    #!${pkgs.bash}/bin/bash
    ${pkgs.conkerorWrapperWithoutScrollbars}/bin/conkeror "$@" &
  '');
  EDITOR="${pkgs.vimHugeX}/bin/vim";
  SHELL = "${pkgs.fish}/bin/fish";
  ASPELL_CONF =
    let
      allDicts = pkgs.buildEnv {
        name = "all-dictionaries";
        paths = builtins.attrValues pkgs.aspellDicts;
        pathsToLink = ["/lib"];
      };
    in "dict-dir ${allDicts}/lib/aspell";
};

# Make SSL root certificates used by Mozilla Firefox available
environment.etc."ssl/certs/mozilla.crt" = {
  source = pkgs.fetchurl {
    url = "http://curl.haxx.se/ca/cacert.pem";
    sha256 = "1ziwf1p9c1980j0v49281f8jzqks5sh9sz8g6jsnn063bias0ibd";
  };
  mode = "444";
};

environment.etc."sync" = {
  source = expr.nixos-sync (config.system.build.nixos-rebuild);
  mode = "500";
};

# Select internationalisation properties.
i18n = {
  consoleFont = "lat9w-16";
  consoleKeyMap = "de-latin1";
  defaultLocale = "en_US.UTF-8";
};
time.timeZone = "Europe/Berlin";


# More fonts!
fonts.fonts = with pkgs; [
  source-code-pro dejavu_fonts liberation_ttf vistafonts corefonts
  cantarell_fonts fira fira-mono
];

networking = {
  hostName = "c-cube";
  wireless.enable = true;
  wireless.interfaces = ["wlo1"];
  wireless.userControlled.enable = true;
};

# Tell systemd that we want to suspend even if an additional
# monitor is connected.
services.logind.extraConfig = ''
  HandleLidSwitchDocked=suspend
'';

# We want volatile storage, so journald doesn't keep the hard
# disk spinning
services.journald.extraConfig = ''
  Storage=volatile
'';

# Allow normal users to mount devices
security.polkit.enable = true;
security.polkit.extraConfig = ''
  polkit.addRule(function(action, subject) {
    var YES = polkit.Result.YES;
    var permission = {
      "org.freedesktop.udisks2.filesystem-mount": YES,
      "org.freedesktop.udisks2.filesystem-mount-system": YES,
      "org.freedesktop.udisks2.eject-media": YES
    };
    return permission[action.id];
  });
'';

nix = {
  useChroot = true;
  extraOptions = ''
    auto-optimise-store = true
  '';
  binaryCaches = [ https://cache.nixos.org ];
  binaryCachePublicKeys = [ "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs=" ];
  trustedBinaryCaches = [
    http://cache.nixos.org
    http://hydra.nixos.org
    http://hydra.cryp.to
    https://ryantrinkle.com:5443
  ];
  daemonNiceLevel = 1;
  daemonIONiceLevel = 1;
};
}
