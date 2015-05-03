{ config, pkgs, ... }: {

imports = [];

# Enable the X11 windowing system.
services.xserver = {
  enable = true;
  videoDrivers = ["ati"];
  layout = "de";
  synaptics.enable = true;
  synaptics.accelFactor = "0.0005";
  synaptics.twoFingerScroll = true;
  xkbOptions = "ctrl:nocaps";

  displayManager.sddm = {
    enable = true;
  };

  displayManager.desktopManagerHandlesLidAndPower = false;
  xrandrHeads = ["VGA-0" "LVDS"];
  desktopManager.session =
    [ { name = "custom";
        start = ''
          ${pkgs.feh}/bin/feh --bg-fill ${/data/pics/wallpapers/Nordsee1.jpg}
          ${pkgs.haskellngPackages.xmobar}/bin/xmobar --screen 0 &
          ${pkgs.xlibs.xrdb}/bin/xrdb -load ${./Xresources}
          ${pkgs.rxvt_unicode}/bin/urxvt -title "IRC bennofs" -e ${pkgs.weechat}/bin/weechat &
          ${pkgs.trayer}/bin/trayer --monitor 1 --edge top --align right --width 10 --height 19 --transparent true --alpha 0 --tint "0xeee8d3" &
          ${pkgs.skype}/bin/skype &
          ${pkgs.hipchat}/bin/hipchat &
          ${pkgs.rxvt_unicode}/bin/urxvtd &
          ${pkgs.gvolicon}/bin/gvolicon &
          ${pkgs.unclutter}/bin/unclutter -idle 3 -grab &
          ${pkgs.pythonPackages.udiskie}/bin/udiskie --tray &
          ${pkgs.dunst}/bin/dunst -key 'mod4+less' -history_key 'mod4+shift+less' -all_key ' ' -cto 4 -nto 2 -lto 1 -config ${./dunstrc} &
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

# Themes and icons

# GTK theme
environment.extraInit = ''
  export GTK_PATH=$GTK_PATH:${pkgs.oxygen_gtk}/lib/gtk-2.0
  export GTK2_RC_FILES=$GTK2_RC_FILES:${pkgs.oxygen_gtk}/share/themes/oxygen-gtk/gtk-2.0/gtkrc
  export XDG_DOWNLOAD_DIR="$HOME/downloads"
'';

environment.systemPackages = with pkgs; [
  # QT icons / themes
  kde4.kdeartwork kde4.l10n.de kde4.oxygen_icons

  # GTK icons / themes
  oxygen_gtk gnome3.gnome_icon_theme hicolor_icon_theme

  # Other packages
  pythonPackages.udiskie
];

# QT / KDE
environment.pathsToLink = [ "/share" ];

# Suspend on LID close
services.logind.extraConfig = "HandleLidSwitch=suspend";

}
