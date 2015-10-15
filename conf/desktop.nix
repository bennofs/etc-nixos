{ config, pkgs, ... }: {

imports = [];

# Enable the X11 windowing system.
services.xserver = {
  enable = true;
  layout = "de";
  synaptics.enable = true;
  synaptics.accelFactor = "0.01";
  synaptics.twoFingerScroll = true;
  synaptics.additionalOptions = ''
    Option "VertScrollDelta" "-112"
    Option "HorizScrollDelta" "-112"
    Option "TapButton2" "3"
    Option "TabButton3" "2"
  '';
  xkbOptions = "ctrl:nocaps";

  displayManager.kdm.enable = true;
  displayManager.desktopManagerHandlesLidAndPower = false;

  desktopManager.session =
    [ { name = "custom";
        start = ''
          ${pkgs.feh}/bin/feh --bg-fill ${/data/pics/wallpapers/unsplash/autumn.jpg}
          ${pkgs.haskellngPackages.xmobar}/bin/xmobar --alpha 200 &
          ${pkgs.trayer}/bin/trayer --edge top --align right --width 10 --height 22 --transparent true --alpha 55 --tint "0xffffff" &
          ${pkgs.xlibs.xrdb}/bin/xrdb -load ${./Xresources}
          ${pkgs.rxvt_unicode}/bin/urxvt -title "IRC bennofs" -e ${pkgs.weechat}/bin/weechat &
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

environment.extraInit = ''
  # GTK theme
  export GTK_PATH=$GTK_PATH:${pkgs.oxygen-gtk2}/lib/gtk-2.0
  export GTK2_RC_FILES=$GTK2_RC_FILES:${pkgs.oxygen-gtk2}/share/themes/oxygen-gtk/gtk-2.0/gtkrc

  # LS colors
  eval `${pkgs.coreutils}/bin/dircolors "${./dircolors}"`
'';

environment.systemPackages = with pkgs; [
  # QT icons / themes
  kde4.kdeartwork kde4.l10n.de kde4.oxygen_icons

  # GTK icons / themes
  gnome3.adwaita-icon-theme hicolor_icon_theme
];

# QT / KDE
environment.pathsToLink = [ "/share" ];

# Suspend on LID close
services.logind.extraConfig = "HandleLidSwitch=suspend";

}
