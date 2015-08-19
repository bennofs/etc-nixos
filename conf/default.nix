{ config, pkgs, expr, ... }:

with builtins; with pkgs.lib; {

imports = [
  ./desktop.nix
  ./services.nix
  ./accounts
];

# Available packages
environment.systemPackages = with pkgs;
  [ git mercurial bazaar subversion unzip wget zip unrar gitAndTools.hub
    pmutils psmisc htop fuse inetutils which binutils scrot xsel
    linuxPackages.perf wpa_supplicant_gui
    bc k2pdfopt ncmpcpp mpc_cli beets arandr
    emacs vimHugeX weechat conkerorWrapperWithoutScrollbars zathura rxvt_unicode keepassx2
    calibre libreoffice wireshark gimp hipchat skype
    nix-repl llvm coq haskellPackages.ghc
    xlibs.xmodmap mplayer
    manpages man expr.armagetronad
  ];

boot.loader.grub.device = "/dev/sda";
boot.initrd.kernelModules = [ "ext4" ];
boot.cleanTmpDir = true;
boot.kernel.sysctl = {
  "kernel.dmesg_restrict" = true;
};
hardware.cpu.amd.updateMicrocode = true;
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

fileSystems."/vms" = {
  label = "vms";
  fsType = "ext4";
};

# Environment variables
environment.variables = {
  BROWSER = builtins.toString (pkgs.writeScript "run-browser.sh" ''
    #!${pkgs.bash}/bin/bash
    ${pkgs.conkerorWrapperWithoutScrollbars}/bin/conkeror "$@" &
  '');
  EDITOR="${pkgs.neovim}/bin/nvim";
  LC_MESSAGES = "en_US.UTF-8";
  LANGUAGE = "de";
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
    sha256 = "1r1ccw9mch23jvchvb12mdska22p75jmh7zmzyxp7jnmyj2flh6z";
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

nix = {
  useChroot = true;
  extraOptions = ''
    auto-optimise-store = true
  '';
  binaryCaches = [ https://cache.nixos.org  http://hydra.cryp.to https://ryantrinkle.com:5443 ];
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
