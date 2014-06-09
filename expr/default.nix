{ pkgs ? import <nixpkgs> {} }: with pkgs;

{

softwarechallenge14-gui = callPackage ./softwarechallenge-gui/2014.nix {};

armagetronad = callPackage ./armagetronad {};

nixHead = callPackage ./nix-head {};

}