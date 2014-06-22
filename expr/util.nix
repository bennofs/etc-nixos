rec {

cabalFilter = haskellPackages: haskellPackages.cabal.override {
  extension = self: super: {
    src =
      let
        ignoredDirs = [ ".git" ".cabal-sandbox" "dist" ];
        ignoredFiles = [ "cabal.sandbox.config" ];
        predicate = path: type:
          !( type == "unknown"
  	  || type == "directory" && builtins.elem (baseNameOf path) ignoredDirs
  	  || type == "regular" && builtins.elem (baseNameOf path) ignoredFiles
  	  );
      in builtins.filterSource predicate super.src;
  };
};

autoHaskell = src: f: { haskellPackages ? (import <nixpkgs> {}).haskellPackages, cabal2nix ? (import /data/apps/cabal2nix) }:
  let projectNix = (import <nixpkgs> {}).runCommand "project.nix" {
        LANG = "en_US.UTF-8";
        LOCALE_ARCHIVE = "${(import <nixpkgs> {}).glibcLocales}/lib/locale/locale-archive";
      } "${cabal2nix}/bin/cabal2nix ${src} > $out";
  in haskellPackages.callPackage (import projectNix) (f haskellPackages // {
    cabal = cabalFilter haskellPackages;
  });

buildHaskell = pkg: f: { haskellPackages ? (import <nixpkgs> {}).haskellPackages }:
  haskellPackages.callPackage (import pkg) (f haskellPackages // {
    cabal = cabalFilter haskellPackages;
  });

useHaskell = src: f: { haskellPackages ? (import <nixpkgs> {}).haskellPackages }:
  (f haskellPackages).override {
    cabal = cabalFilter haskellPackages;
  };
}