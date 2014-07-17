rec {

lib = (import <nixpkgs> {}).lib;

filterHaskellSrc = src:
  let
    ignoredDirs = [ ".git" ];
    ignoredFiles = [ "cabal.sandbox.config" ];
    predicate = path: type:
         !( type == "unknown"
         || type == "directory" && (builtins.elem (baseNameOf path) ignoredDirs
                                 || lib.hasPrefix ".nix" (baseNameOf path)
                                 || lib.hasPrefix "dist" (baseNameOf path)
                                 || lib.hasSuffix "cabal-sandbox" (baseNameOf path)
                                 )
         || type == "regular" && builtins.elem (baseNameOf path) ignoredFiles
         );
  in if builtins.typeOf src == "path"
    then builtins.filterSource predicate src
    else src;

cabalFilter = haskellPackages: haskellPackages.cabal.override {
  extension = self: super: {
    src = filterHaskellSrc super.src;
  };
};

autoHaskell = src: f: { haskellPackages ? (import <nixpkgs> {}).haskellPackages, cabal2nix ? (import /data/apps/cabal2nix { inherit haskellPackages; }) }:
  let
    filtered = filterHaskellSrc src;
    projectNix = (import <nixpkgs> {}).runCommand "project.nix" {
      LANG = "en_US.UTF-8";
      LOCALE_ARCHIVE = "${(import <nixpkgs> {}).glibcLocales}/lib/locale/locale-archive";
    } "${cabal2nix}/bin/cabal2nix ${filtered} > $out";
  in haskellPackages.callPackage (import projectNix) (f haskellPackages // {
    cabal = haskellPackages.cabal.override { extension = self: super: { src = filtered; }; };
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