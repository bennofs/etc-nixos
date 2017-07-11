let
  configuration = { config, pkgs, ... }: {

    imports = [ ./conf/default.nix ./vm-accounts.nix ];

    nixpkgs.config = import ./conf/nixpkgs.nix;
    _module.args.expr = import ./expr { inherit pkgs; };
    _module.args.buildVM = true;

     # Set VM disk size (in MB)
     virtualisation.diskSize = 2048;

     # Set VM ram amount (in MB)
     virtualisation.memorySize = 1024;

  };
  build = import <nixpkgs/nixos> { inherit configuration; };
in build.vm
