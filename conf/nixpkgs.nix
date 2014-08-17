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
  rxvt_unicode = pkgs.stdenv.lib.overrideDerivation pkgs.rxvt_unicode (old: {
    preConfigure = ''
      ${old.preConfigure}
      configureFlags="$configureFlags --enable-unicode3";
    '';
  });
};

}
