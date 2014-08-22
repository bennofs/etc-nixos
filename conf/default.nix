{ config, expr, pkgs, ... }:

with builtins; with pkgs.lib; {

imports = [
  <nixos/modules/programs/virtualbox.nix>
  ./desktop.nix
  ./services.nix
  ./accounts
  expr.hydraModule
];

nixpkgs.config = import ./nixpkgs.nix;

# Available packages
environment.systemPackages = with pkgs;
  [ git mercurial bazaar subversion unzip wget zip unrar gitAndTools.hub
    pmutils psmisc htop fuse inetutils samba which binutils patchelf scrot
    linuxPackages.perf wpa_supplicant_gui gnuplot
    nmap bc vagrant
    emacs weechat skype calibre rxvt_unicode zathura hipchat wireshark gimp libreoffice
    dwbWrapper firefoxWrapper
    expr.k2pdfopt ncmpc mpc_cli
    ruby python python3 nix-repl texLiveFull ghostscript llvm
    (with haskellPackages; [hasktags hlint xmobar dmenu cabalInstall ghcPlain])
    xlibs.xmodmap mplayer youtubeDL
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
  BROWSER = "${pkgs.dwbWrapper}/bin/dwb";
  LC_MESSAGES = "en_US.UTF-8";
  LANGUAGE = "de";
  SHELL = "${pkgs.fish}/bin/fish";
};

# dumpcap is needed for wireshark
security.setuidPrograms = ["dumpcap"];
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
  gc.automatic = true;
  daemonNiceLevel = 1;
  daemonIONiceLevel = 1;
};
}
