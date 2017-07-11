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

armagetronad = callPackage ./armagetronad {};

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

hydra =
  let
    source = fetchgit {
      url = "https://github.com/mayflower/hydra";
      rev = "6216eeb7d9b3de922100f2afebc2b5e11aac6726";
      sha256 = "1y5zqy7y3ghizpqcph71apjkzjkczn1gb4ia301d6an6sdk2ybjz";
    };
  in (import "${source}/release.nix" {}).build."${system}";

radare2-git = callPackage ./radare2-git { };

}
