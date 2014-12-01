{

allowUnfree = true;
virtualbox.enableExtensionPack = true;
chromium.enablePepperFlash = true;
chromium.enablePepperPDF = true;
dmenu.enableXft = true;
dwb.enableAdobeFlash = true;
firefox.enableAdobeFlash = true;
cabal.libraryProfiling = true;
packageOverrides = pkgs: rec {
  rxvt_unicode = pkgs.rxvt_unicode.overrideDerivation (old: {
    preConfigure = ''
      ${old.preConfigure}
      configureFlags="$configureFlags --enable-unicode3";
    '';
  });
  trayer = pkgs.trayer.overrideDerivation (old: {
    patches = [ ./patches/trayer-force-icon-width.patch ];
  });
};

}
