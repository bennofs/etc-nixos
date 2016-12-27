{ pkgs ? import <nixpkgs> {} }: with pkgs;

rec {

softwarechallenge14-gui = callPackage ./softwarechallenge-gui/2014.nix {};

softwarechallenge15-gui = callPackage ./softwarechallenge-gui/2015.nix {
  jre = oraclejre8;
};

softwarechallenge16-gui = callPackage ./softwarechallenge-gui/2016.nix {
  jre = oraclejre8;
};

esu = callPackage ./esu {};

armagetronad = callPackage ./armagetronad {
  gnugrep = gnugrep.overrideDerivation (old: {
    patches = (old.patches or []) ++ [ ../conf/patches/grep-fix-splice-einval.patch ];
  });
};

nixos-sync = nixos-rebuild: callPackage ./nixos-sync {
  git = gitMinimal;
  inherit nixos-rebuild;
};

lock = callPackage ./lock {
  inherit (xlibs) xprop;
};

lock-suspend = callPackage ./lock-suspend {
  inherit lock;
};

asurocon = callPackage ./asurocon {};

mfcj430w-driver = pkgsi686Linux.callPackage ./mfcj430w-driver {
  psnup = texlive.combined.scheme-minimal;
};

}
