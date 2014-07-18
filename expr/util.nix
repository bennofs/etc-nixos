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

autoHaskell = src: local:
  { haskellPackages ? (import <nixpkgs> {}).haskellPackages,
    cabal2nix ? (import /data/apps/cabal2nix { inherit haskellPackages; })
  }:
  let
    filtered = filterHaskellSrc src;
    projectNix = (import <nixpkgs> {}).runCommand "project.nix" {
      LANG = "en_US.UTF-8";
      LOCALE_ARCHIVE = "${(import <nixpkgs> {}).glibcLocales}/lib/locale/locale-archive";
    } "${cabal2nix}/bin/cabal2nix ${filtered} > $out";
    haskellPackagesOverride = haskellPackages.override {
      extension = self: super:
        lib.mapAttrs
          (_: x: import x { haskellPackages = haskellPackagesOverride; })
          local;
    };
  in haskellPackagesOverride.callPackage (import projectNix) {
    cabal = haskellPackages.cabal.override {
      extension = self: super: { src = filtered; };
    };
  };

useHaskell = src: f: { haskellPackages ? (import <nixpkgs> {}).haskellPackages }:
  (f haskellPackages).override {
    cabal = cabalFilter haskellPackages;
  };
}