{ config, pkgs, expr, buildVM, ... }:

let
  iconTheme = pkgs.kde5.breeze-icons.out;
  themeEnv = ''
    # QT: remove local user overrides (for determinism, causes hard to find bugs)
    rm -f ~/.config/Trolltech.conf

    # GTK3: remove local user overrides (for determinisim, causes hard to find bugs)
    rm -f ~/.config/gtk-3.0/settings.ini

    # GTK3: add breeze theme to search path for themes
    # (currently, we need to use gnome-breeze because the GTK3 version of kde5.breeze is broken)
    export XDG_DATA_DIRS="${pkgs.gnome-breeze}/share:$XDG_DATA_DIRS"

    # GTK3: add /etc/xdg/gtk-3.0 to search path for settings.ini
    # We use /etc/xdg/gtk-3.0/settings.ini to set the icon and theme name for GTK 3
    export XDG_CONFIG_DIRS="/etc/xdg:$XDG_CONFIG_DIRS"

    # GTK2 theme + icon theme
    export GTK2_RC_FILES=${pkgs.writeText "iconrc" ''gtk-icon-theme-name="breeze"''}:${pkgs.kde5.breeze}/share/themes/Breeze/gtk-2.0/gtkrc:$GTK2_RC_FILES

    # SVG loader for pixbuf (needed for GTK svg icon themes)
    export GDK_PIXBUF_MODULE_FILE=$(echo ${pkgs.librsvg.out}/lib/gdk-pixbuf-2.0/*/loaders.cache)

    # LS colors
    eval `${pkgs.coreutils}/bin/dircolors "${./dircolors}"`
  '';

in {

imports = [];

# Required for our screen-lock-on-suspend functionality
services.logind.extraConfig = ''
  LidSwitchIgnoreInhibited=False
  HandleLidSwitch=suspend
  HoldoffTimeoutSec=10
'';

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
    Option "TapButton3" "2"
  '';
  xkbOptions = "ctrl:nocaps";

  displayManager.logToJournal = true;
  displayManager.lightdm.enable = true;
  displayManager.lightdm.autoLogin = {
    enable = true;
    user = "benno";
  };
  displayManager.lightdm.greeter.enable = false;
  desktopManager.session =
    [ { name = "custom";
        start = ''
          # Lock
          ${expr.lock}/bin/lock
          ${expr.lock-suspend}/bin/lock-on-suspend &

          ${pkgs.feh}/bin/feh --bg-fill ${/data/pics/wallpapers/unsplash/autumn.jpg}
          ${pkgs.haskellPackages.xmobar}/bin/xmobar --dock --alpha 200 &
          ${pkgs.stalonetray}/bin/stalonetray --slot-size 22 --icon-size 20 --geometry 9x1-0 --icon-gravity NE --grow-gravity E -c /dev/null --kludges fix_window_pos,force_icons_size,use_icons_hints --transparent --tint-level 200 &> /dev/null &
          ${pkgs.xlibs.xrdb}/bin/xrdb -load ${./Xresources}

          # Autostart
          ${pkgs.lib.optionalString (!buildVM) ''
            ${pkgs.rxvt_unicode}/bin/urxvt -title "IRC bennofs" -e ${pkgs.weechat}/bin/weechat &
            ${pkgs.skype}/bin/skype &
          ''}
          ${pkgs.rxvt_unicode}/bin/urxvtd &
          ${pkgs.emacs}/bin/emacs --daemon &
          ${pkgs.gvolicon}/bin/gvolicon &> /dev/null &
          ${pkgs.unclutter}/bin/unclutter -idle 3 &
          ${pkgs.pythonPackages.udiskie}/bin/udiskie --tray &
          ${pkgs.wpa_supplicant_gui}/bin/wpa_gui -q -t &
          ${pkgs.dunst}/bin/dunst -cto 4 -nto 2 -lto 1 -config ${./dunstrc} &
          syndaemon -i 1 -R -K -t -d
          trap 'trap - SIGINT SIGTERM EXIT && kill 0 && wait' SIGINT SIGTERM EXIT
          ${pkgs.lib.optionalString buildVM '' ${pkgs.rxvt_unicode}/bin/urxvt '' }
        '';
      }
      { name = "emacs";
        start = ''
          ${pkgs.xorg.xhost}/bin/xhost +
          # Lock
          ${expr.lock}/bin/lock
          ${expr.lock-suspend}/bin/lock-on-suspend &

          ${pkgs.feh}/bin/feh --bg-fill ${/data/pics/wallpapers/unsplash/autumn.jpg}
          ${pkgs.haskellPackages.xmobar}/bin/xmobar --dock --alpha 200 &
          ${pkgs.stalonetray}/bin/stalonetray --slot-size 22 --icon-size 20 --geometry 9x1-0 --icon-gravity NE --grow-gravity E -c /dev/null --kludges fix_window_pos,force_icons_size,use_icons_hints --transparent --tint-level 200 &> /dev/null &
          ${pkgs.xlibs.xrdb}/bin/xrdb -load ${./Xresources}

          # Autostart
          ${pkgs.lib.optionalString (!buildVM) ''
            ${pkgs.skype}/bin/skype &
          ''}
          ${pkgs.rxvt_unicode}/bin/urxvtd &
          ${pkgs.gvolicon}/bin/gvolicon &> /dev/null &
          ${pkgs.unclutter}/bin/unclutter -idle 3 &
          ${pkgs.pythonPackages.udiskie}/bin/udiskie --tray &
          ${pkgs.wpa_supplicant_gui}/bin/wpa_gui -q -t &
          ${pkgs.dunst}/bin/dunst -cto 4 -nto 2 -lto 1 -config ${./dunstrc} &
          syndaemon -i 1 -R -K -t -d
          trap 'trap - SIGINT SIGTERM EXIT && kill 0 && wait' SIGINT SIGTERM EXIT
          ${pkgs.lib.optionalString buildVM '' ${pkgs.rxvt_unicode}/bin/urxvt '' }
          env EMACS_WM=1 ${pkgs.emacs}/bin/emacs
        '';
      }
    ];
  desktopManager.default = "emacs";
  desktopManager.xterm.enable = false;

  windowManager.default = "none";
  windowManager.xmonad.enable = true;
  windowManager.xmonad.enableContribAndExtras = true;

  wacom.enable = true;
};

environment.extraInit = ''
  ${themeEnv}

  # these are the defaults, but some applications are buggy so we set them
  # here anyway
  export XDG_CONFIG_HOME=$HOME/.config
  export XDG_DATA_HOME=$HOME/.local/share
  export XDG_CACHE_HOME=$HOME/.cache
'';

# QT4/5 global theme
environment.etc."xdg/Trolltech.conf" = {
  text = ''
    [Qt]
    style=Breeze
  '';
  mode = "444";
};

# GTK3 global theme (widget and icon theme)
environment.etc."xdg/gtk-3.0/settings.ini" = {
  text = ''
    [Settings]
    gtk-icon-theme-name=breeze
    gtk-theme-name=Breeze-gtk
  '';
  mode = "444";
};

environment.systemPackages = with pkgs; [
  # Qt theme
  kde5.breeze

  # Icons (Main)
  iconTheme

  # Icons (Fallback)
  gnome3.adwaita-icon-theme
  hicolor_icon_theme

  # These packages are used in autostart, they need to in systemPackages
  # or icons won't work correctly
  pythonPackages.udiskie skype
];

# Make applications find files in <prefix>/share
environment.pathsToLink = [ "/share" ];

}
