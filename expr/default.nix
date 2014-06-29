{ pkgs ? import <nixpkgs> {} }: with pkgs;

rec {

softwarechallenge14-gui = callPackage ./softwarechallenge-gui/2014.nix {};

armagetronad = callPackage ./armagetronad {};

nixHead = callPackage ./nix-head {};

girara = callPackage ./girara {};

jumanji = callPackage ./jumanji { girara = callPackage ./girara {}; };

jumanjiWrapper = wrapFirefox
  { browser = jumanji; browserName = "jumanji"; desktopName = "Jumanji";
  };

}