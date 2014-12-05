{ config, expr, pkgs, ... }:

with builtins; with pkgs.lib; {

imports = [
  ./desktop.nix
  ./services.nix
  ./accounts
  expr.hydraModule
];

nixpkgs.config = import ./nixpkgs.nix;

# Available packages
environment.systemPackages = with pkgs;
  [ git mercurial bazaar subversion unzip wget zip unrar gitAndTools.hub
    pmutils psmisc htop fuse inetutils samba which binutils scrot xsel
    linuxPackages.perf wpa_supplicant_gui gnuplot
    nmap bc libvirt expr.k2pdfopt ncmpc mpc_cli
    emacs weechat skype calibre rxvt_unicode zathura wireshark gimp libreoffice hipchat
    conkerorWrapper
    ruby python python3 nix-repl texLiveFull ghostscript llvm
    (with haskellPackages; [hasktags hlint xmobar dmenu cabalInstall ghcPlain])
    xlibs.xmodmap xclip mplayer youtubeDL
    neverball csound manpages
    expr.armagetronad
  ];

boot.loader.grub.device = "/dev/sda";
boot.initrd.kernelModules = [ "ext4" ];
boot.cleanTmpDir = true;
hardware.cpu.amd.updateMicrocode = true;

fileSystems."/data" = {
  label = "data";
  fsType = "ext4";
};

# Environment variables
environment.variables = {
  BROWSER = builtins.toString (pkgs.writeScript "run-browser.sh" ''
    #!${pkgs.bash}/bin/bash
    ${pkgs.conkerorWrapper}/bin/conkeror "$@" &
  '');
  LC_MESSAGES = "en_US.UTF-8";
  LANGUAGE = "de";
  SHELL = "${pkgs.fish}/bin/fish";
};

# Make SSL root certificates used by Mozilla Firefox available
environment.etc."ssl/certs/mozilla.crt" = {
  source = pkgs.fetchurl {
    url = "http://curl.haxx.se/ca/cacert.pem";
    sha256 = "1r1ccw9mch23jvchvb12mdska22p75jmh7zmzyxp7jnmyj2flh6z";
  };
  mode = "444";
};

# dumpcap is needed for wireshark
security.setuidPrograms = ["dumpcap" "slock"];
security.sudo.enable = true;

# Select internationalisation properties.
i18n = {
  consoleFont = "lat9w-16";
  consoleKeyMap = "de-latin1";
  defaultLocale = "de_DE.UTF-8";
};


# More fonts!
fonts.fonts = with pkgs; [
  source-code-pro dejavu_fonts liberation_ttf vistafonts corefonts
  cantarell_fonts
];

networking = {
  hostName = "c-cube";
  wireless.enable = true;
  wireless.interfaces = ["wlo1"];
  wireless.userControlled.enable = true;
};

nix = {
  extraOptions = ''
    build-use-chroot = true
    auto-optimise-store = true
  '';
  package = pkgs.nixUnstable;
  trustedBinaryCaches = [
    http://cache.nixos.org
    http://hydra.nixos.org
    http://hydra.cryp.to
  ];
  daemonNiceLevel = 1;
  daemonIONiceLevel = 1;
};
}
