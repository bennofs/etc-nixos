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
         || type == "symlink"
         );
  in if builtins.typeOf src == "path"
    then builtins.filterSource predicate src
    else src;

cabalFilter = haskellPackages: haskellPackages.cabal.override {
  extension = self: super: {
    src = filterHaskellSrc super.src;
  };
};

autoHaskell = src: overrides:
  { haskellPackages ? (import <nixpkgs> {}).haskellPackages,
    cabal2nix ? (import <nixpkgs> {}).haskellPackages.cabal2nix,
    versions ? {}
  }:
  let
    filtered = filterHaskellSrc src;
    projectNix = (import <nixpkgs> {}).runCommand "project.nix" {
      LANG = "en_US.UTF-8";
      LOCALE_ARCHIVE = "${(import <nixpkgs> {}).glibcLocales}/lib/locale/locale-archive";
    } "${cabal2nix}/bin/cabal2nix ${filtered} > $out";
    haskellPackagesOverride = haskellPackages.override (old: {
      extension = self: super: (if old ? extension then old.extension self super else {}) // (lib.mapAttrs resolvePackage (overrides // versions));
    });
    resolvePackage = name: override:
      let
        version = lib.replaceChars ["."] ["_"] override;
        attrname = name + "_" + version;
        matching = lib.filterAttrs (n: _: lib.hasPrefix attrname n) haskellPackagesOverride;
        matchingDerivs = lib.attrValues matching;
        tooManyPkgs = "autoHaskell: more than one package matching " + attrname;
      in if builtins.typeOf override == "path"
        then import override { haskellPackages = haskellPackagesOverride; }
        else if builtins.length matchingDerivs > 1
          then builtins.throw (tooManyPkgs
            + "\n  matching: " + lib.concatStringsSep " " (builtins.attrNames matching))
          else if builtins.length matchingDerivs < 1
            then builtins.throw ("autoHaskell: No package matching " + attrname)
            else builtins.head matchingDerivs;

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
