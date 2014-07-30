# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, expr, pkgs, ... }:

with builtins; with pkgs.lib; {

  imports =
    [ <nixos/modules/programs/virtualbox.nix>
    ];

  nixpkgs.config = import ./nixpkgs.nix;

  # Available packages
  environment.systemPackages = with pkgs;
    [ git mercurial bazaar subversion unzip wget zip unrar gitAndTools.hub
      pmutils psmisc htop fuse inetutils samba which binutils patchelf scrot linuxPackages.perf wpa_supplicant_gui gnuplot
      nmap bc vagrant
      emacs chromiumWrapper weechat skype calibre rxvt_unicode zathura hipchat wireshark blender gimp libreoffice dwbWrapper
      expr.k2pdfopt ncmpc mpc_cli
      ruby python python3 nix-repl texLiveFull ghostscript llvm haskellPackages.hasktags
      haskellPackages.cabalInstall haskellPackages.hlint (pkgs.haskellPackages.ghcWithPackagesOld (hs: with hs; [
        Cabal_1_20_0_1 ghcPaths cpphs hlint
	zlib text textIcu async hinotify systemFilepath haskeline unixMemory systemTimeMonotonic curl
	cairo pango glib gio gtk vty OpenGLRaw bmp GLUT
        lens pipes pipesConcurrency pipesNetwork pipesParse pipesText aeson network optparseApplicative criterion wreq xmlLens uniplate
	conduit xmlConduit httpConduit htmlConduit
	either mtl monadControl mmorph bifunctors profunctors errors liftedBase transformers transformersBase dataDefault monadLoops
        regexApplicative thLift thLiftInstances linear vectorSpace
	tasty tastyTh HUnit tastyHunit haskellSrcExts QuickCheck tastyQuickcheck quickcheckPropertyMonad doctest
        wlPprint colour Boolean
      ]))
      haskellPackages.xmobar dmenu xlibs.xmodmap mplayer youtubeDL
      neverball csound manpages
      expr.armagetronad expr."softwarechallenge14-gui"

      # QT icons / themes
      kde4.kdeartwork kde4.l10n.de kde4.oxygen_icons

      # GTK icons / themes
      oxygen_gtk gnome3.gnome_icon_theme hicolor_icon_theme

    ];

  boot.loader.grub.device = "/dev/sda";
  boot.initrd.kernelModules = ["ext4"];
  boot.cleanTmpDir = true;
  hardware.cpu.amd.updateMicrocode = true;

  fileSystems."/data" = {
    label = "data";
    fsType = "ext4";
  };

  # Environment variables
  environment.variables = {
    BROWSER = "${pkgs.dwbWrapper}/bin/dwb";
    LC_MESSAGES = "en_US.UTF-8";
    LANGUAGE = "de";
    SHELL = "${pkgs.fish}/bin/fish";
  };

  # GTK theme
  environment.shellInit = ''
    export GTK_PATH=$GTK_PATH:${pkgs.oxygen_gtk}/lib/gtk-2.0
    export GTK2_RC_FILES=$GTK2_RC_FILES:${pkgs.oxygen_gtk}/share/themes/oxygen-gtk/gtk-2.0/gtkrc
    '';

  # dumpcap is needed for wireshark
  security.setuidPrograms = ["dumpcap"];
  security.sudo.enable = true;

  # Select internationalisation properties.
  i18n = {
    consoleFont = "lat9w-16";
    consoleKeyMap = "de-latin1";
    defaultLocale = "de_DE.UTF-8";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Suspend on LID close
  services.logind.extraConfig = "HandleLidSwitch=suspend";

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    videoDrivers = ["ati"];
    layout = "de";
    synaptics.enable = true;
    synaptics.accelFactor = "0.0005";
    synaptics.twoFingerScroll = true;
    xkbOptions = "";

    displayManager.slim = {
      enable = true;
      defaultUser = "benno";
      autoLogin = true;
      theme = pkgs.fetchurl {
        url = mirror://sourceforge/slim.berlios/slim-scotland-road.tar.gz;
        sha256 = "18dvyfiprybmqvzyvv72lij2zlbcndbm87psiyb9plvf94sa8q7x";
      };
    };
    displayManager.desktopManagerHandlesLidAndPower = false;

    desktopManager.session =
      [ { name = "custom";
          start = ''
            ${pkgs.feh}/bin/feh --bg-fill ${/data/pics/wallpapers/Echo/robocop_d.jpg}
            ${pkgs.haskellPackages.xmobar}/bin/xmobar &
            ${pkgs.xlibs.xrdb}/bin/xrdb -load ${./Xresources}
            ${pkgs.trayer}/bin/trayer --edge top --align right --width 10 --height 19 --transparent true --alpha 0 --tint "0x001212" &
            ${pkgs.xcompmgr}/bin/xcompmgr &
            ${pkgs.skype}/bin/skype &
            ${pkgs.rxvt_unicode}/bin/urxvtd &
            ${pkgs.rxvt_unicode}/bin/urxvt -title "IRC bennofs" -e ${pkgs.weechat}/bin/weechat &
            ${pkgs.dwbWrapper}/bin/dwb &
            ${pkgs.xlibs.xmodmap}/bin/xmodmap ${./xmodmap}
            ${pkgs.gvolicon}/bin/gvolicon &
            ${pkgs.unclutter}/bin/unclutter -idle 3 -grab &
            syndaemon -i 1 -R -K -t -d
          '';
      } ];
    desktopManager.default = "custom";
    desktopManager.xterm.enable = false;

    windowManager.default = "xmonad";
    windowManager.xmonad.enable = true;
    windowManager.xmonad.enableContribAndExtras = true;

    wacom.enable = true;
  };

  # Make KDE apps work (icons, etc)
  environment.pathsToLink = [ "/share" ];

  # mpd
  services.mpd.enable = true;
  services.mpd.musicDirectory = "/data/music";

  # More fonts!
  fonts.fonts = with pkgs; [
    inconsolata dejavu_fonts liberation_ttf vistafonts corefonts cantarell_fonts
  ];

  # Configure one additional user
  users.mutableUsers = false;
  users.defaultUserShell = "/run/current-system/sw/bin/bash";
  users.extraUsers.benno = {
    description = "Benno Fünfstück";
    uid = 1000;
    passwordFile = "/etc/nixos/conf/accounts/benno";
    createHome = true;
    home = "/home";
    extraGroups = [ "wheel" "vboxusers" ];
    useDefaultShell = true;
  };
  security.initialRootPassword = "!";

  networking = {
    hostName = "c-cube";
    wireless.enable = true;
    wireless.interfaces = ["wlo1"];
    wireless.userControlled.enable = true;
  };

  services.tor.client = {
    enable = true;
    privoxy.enable = true;
    privoxy.listenAddress = "0.0.0.0:8118";
  };

  # Enable remote access via SSH and a SSH web-interface on :4200
  services.openssh.enable = true;
  jobs.shellinaboxd = {
    description = "Shellinabox daemon";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    setuid = "nobody";
    exec = "${pkgs.shellinabox}/bin/shellinaboxd";
  };

  services.samba = {
    enable = true;
    defaultShare.enable = true;
    defaultShare.guest = false;
    securityType = "share";
    extraConfig = ''
      workgroup = WORKGROUP
    '';
  };

  networking.firewall = {
    allowPing = true;
    allowedTCPPorts = [ 80 445 139 4200 ];
    allowedUDPPorts = [ 137 138 ];
  };

  nix.extraOptions = ''
    build-use-chroot = true
    '';
  nix.package = pkgs.nixUnstable;
  nix.trustedBinaryCaches = [ http://cache.nixos.org http://hydra.nixos.org ];
}
