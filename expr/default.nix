{ pkgs ? import <nixpkgs> {} }: with pkgs;

rec {

softwarechallenge14-gui = callPackage ./softwarechallenge-gui/2014.nix {};

armagetronad = callPackage ./armagetronad {};

rustHead = callPackage ./rust-head {};

hydra = (import ./hydra/release.nix {}).build.${builtins.currentSystem};

hydraModule = ./hydra/hydra-module.nix;

k2pdfopt = callPackage ./k2pdfopt {};

}