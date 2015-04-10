{ config, pkgs, ... }: {
imports = [ ./hardware-configuration.nix ./conf/default.nix ];
nixpkgs.config = import ./conf/nixpkgs.nix;
_module.args.expr = import ./expr { inherit pkgs; };
}
