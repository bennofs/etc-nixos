{ config, pkgs, expr, ... }:

with builtins; with pkgs.lib; {

imports = [
  ./desktop.nix
  ./services.nix
];

# Available packages
environment.systemPackages = with pkgs;
  [ # Version control / archiving
    git gitAndTools.hub mercurial bazaar subversion
    unzip zip unrar p7zip dtrx

    # Debugging / monitoring / analyzing
    htop iotop powertop
    ltrace strace linuxPackages.perf
    pciutils lshw smartmontools usbutils

    # Networking
    inetutils wireshark wget nix-prefetch-scripts

    # Linux shell utils
    pmutils psmisc which file binutils bc utillinuxCurses exfat dosfstools
    patchutils moreutils

    # Desktop utils
    scrot xsel xlibs.xbacklight arandr wpa_supplicant_gui expr.lock pavucontrol paprefs

    # Command line programs
    k2pdfopt ncmpcpp mpc_cli beets wpa_supplicant mp3gain mpv
    fish haskellPackages.themplate abcde vorbisgain dfc ripgrep
    aspell weechat

    # Man pages
    man man-pages posix_man_pages stdman

    # Development tools
    nix-repl llvm haskellPackages.ghc

    # Desktop applications
    xfce.thunar gimp skype libreoffice calibre emacs
    keepassx2 zathura rxvt_unicode chromium steam vlc

    # Games
    expr.armagetronad steam
  ];

boot.cleanTmpDir = true;
boot.kernel.sysctl = {
  "kernel.dmesg_restrict" = true;
};
hardware.pulseaudio.enable = true;
hardware.pulseaudio.support32Bit = true;
hardware.pulseaudio.package = pkgs.pulseaudioFull;
hardware.bluetooth.enable = true;
hardware.opengl.driSupport32Bit = true;

services.udev.packages = with pkgs; [
  # Enable Android udev rules
  # This is needed so that the android device nodes in /dev have
  # the correct access levels (they will be managed by systemd-logind)
  libmtp
];
services.udev.extraRules = ''
  # AREXX USB-IR-Transceiver. For flashing ASURO robot
  SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", ENV{ID_REMOTE_CONTROL}="1"

  # Wiko android devices
  ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0bb4", SYMLINK+="libmtp-%k", ENV{ID_MTP_DEVICE}="1", ENV{ID_MEDIA_PLAYER}="1"

  # set deadline scheduler for non-rotating disks
  ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="deadline"

  # spindown /dev/sda after 5 minutes of inactivity
  ACTION=="add", SUBSYSTEM=="block", KERNEL=="sda", RUN+="${pkgs.hdparm}/bin/hdparm -S 60 /dev/sda"
'';

# Environment variables
environment.variables = {
  BROWSER ="${pkgs.chromium}/bin/chromium";
  EDITOR="${pkgs.emacs}/bin/emacsclient -c";
  SHELL = "${pkgs.fish}/bin/fish";
};

# Ugh, the default 'extraInit' has code to override ASPELL_DICTS, so we need
# to set our ASPELL_DICT environment variable after that code has executed.
# shellInit is executed after extraInit.
environment.shellInit =
  let
    allDicts = pkgs.buildEnv {
      name = "all-dictionaries";
      paths = builtins.attrValues pkgs.aspellDicts;
      pathsToLink = ["/lib"];
    };
  in ''export ASPELL_CONF="dict-dir ${allDicts}/lib/aspell"'';

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

# Setup /home
system.activationScripts.homeUser = stringAfter [ "users" ] ''
  chown benno:users /home
'';

# Make sure /run/media/benno exists
system.activationScripts.mediaMountPoint = ''
  mkdir -p /run/media/benno
  chown benno:users /run/media/benno
'';


# Extra environment variables
environment.extraInit = ''
  export PATH="$HOME/.local/bin:$PATH"
'';

environment.loginShellInit = ''

  if [ ! -d /home/.git ]; then
    pushd
    cd /home
    git=${pkgs.git}/bin/git
    $git init &> /tmp/git-init
    $git remote add origin https://github.com/bennofs/dotfiles &> /tmp/git-remote
    $git fetch &> /tmp/git-fetch
    $git checkout -t origin/master &> /tmp/git-checkout
    popd

    # Setup nix-env
    rm /home/.nix-defexpr/*
    ln -s /run/current-system/nixpkgs /home/.nix-defexpr
  fi
'';

# Add nixpkgs link to system
system.extraSystemBuilderCmds = ''
  cp -r ${builtins.filterSource (name: _: baseNameOf name != ".git") <nixpkgs>} $out/nixpkgs
'';

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
  cantarell_fonts fira fira-mono fira-code hasklig
];

networking = {
  hostName = "c-cube";
  wireless.enable = true;
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
  useSandbox = "relaxed";
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
  nixPath = [
    "nixpkgs=/run/current-system/nixpkgs"
    "/run/current-system/nixpkgs"
    "nixos-config=/etc/nixos/configuration.nix"
  ];
  buildMachines = [
    { hostName = "localhost"; system = builtins.currentSystem; inherit (config.nix) maxJobs; } 
  ];
};

}

