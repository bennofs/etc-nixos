{ prof ? true }:

let

  nixpkgs = import <nixpkgs> {
    config = {
      cabal.libraryProfiling = prof;            
    };
  };
  util = import ../util.nix;

in nixpkgs.haskellPackages_ghc782.override {
  extension = hsself: hssuper: {
    cabal = nixpkgs.haskellPackages_ghc782.cabal.override {
      extension = self: super: {
        noHaddock = true;
      };
    };
  };
}