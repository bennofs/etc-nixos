{ pkgs ? import <nixpkgs> {} }: with pkgs;

rec {

softwarechallenge14-gui = callPackage ./softwarechallenge-gui/2014.nix {};

softwarechallenge15-gui = callPackage ./softwarechallenge-gui/2015.nix {
  jre = oraclejre8;
};

esu = callPackage ./esu {};

armagetronad = callPackage ./armagetronad {};

rustHead = callPackage ./rust-head {};

hydra = (import ./hydra/release.nix {}).build.${builtins.currentSystem};

hydraModule = ./hydra/hydra-module.nix;

nixos-sync = nixos-rebuild: callPackage ./nixos-sync {
  git = gitMinimal;
  inherit nixos-rebuild;
};

}
