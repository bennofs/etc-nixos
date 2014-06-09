rec {

buildHaskell = pkg: f: { haskellPackages ? (import <nixpkgs> {}).haskellPackages }: 
  haskellPackages.callPackage (import pkg) (f haskellPackages // {
    cabal = haskellPackages.cabal.override { 
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
  });

useHaskell = src: f: { haskellPackages ? (import <nixpkgs> {}).haskellPackages }:
  (f haskellPackages).override {
    cabal = haskellPackages.cabal.override { 
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
          in builtins.filterSource predicate src;
      };
    };
  };

}