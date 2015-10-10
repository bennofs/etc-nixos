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

asurocon = callPackage ./asurocon {};

}
