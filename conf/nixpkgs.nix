{
allowUnfree = true;
chromium.enablePepperFlash = true;
chromium.enablePepperPDF = true;
cabal.libraryProfiling = true;
packageOverrides = pkgs: rec {
  rxvt_unicode = pkgs.rxvt_unicode.overrideDerivation (old: {
    preConfigure = ''
      ${old.preConfigure}
      configureFlags="$configureFlags --enable-unicode3";
    '';
  });

  custom = import ../expr { inherit pkgs; };

  trayer = pkgs.trayer.overrideDerivation (old: {
    patches = [ ./patches/trayer-force-icon-width.patch ];
  });

  conkerorWrapperWithoutScrollbars = pkgs.lib.overrideDerivation pkgs.conkerorWrapper (old: rec {
    disableScrollbars = pkgs.writeText "conkeror-gtk2-no-scrollbars.rc" ''
      style "noscrollbars" {
        GtkScrollbar::slider-width=0
        GtkScrollbar::trough-border=0
        GtkScrollbar::has-backward-stepper=0
        GtkScrollbar::has-forward-stepper=0
        GtkScrollbar::has-secondary-backward-stepper=0
        GtkScrollbar::has-secondary-forward-stepper=0
      }
      widget "MozillaGtkWidget.*" style "noscrollbars"
    '';
    buildCommand = ''
      ${old.buildCommand}
      wrapProgram $out/bin/conkeror \
        --prefix GTK2_RC_FILES ":" ${disableScrollbars}
    '';
  });
};

}
