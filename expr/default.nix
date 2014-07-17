{ pkgs ? import <nixpkgs> {} }: with pkgs;

rec {

softwarechallenge14-gui = callPackage ./softwarechallenge-gui/2014.nix {};

armagetronad = callPackage ./armagetronad {};

nixHead = callPackage ./nix-head {};

rustHead = callPackage ./rust-head {};

}