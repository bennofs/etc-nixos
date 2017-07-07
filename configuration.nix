{ config, pkgs, ... }: {
imports = [ ./hardware-overrides.nix ./conf/default.nix ];
nixpkgs.config = import ./conf/nixpkgs.nix;
_module.args.expr = import ./expr { inherit pkgs; };
_module.args.buildVM = false;
}
