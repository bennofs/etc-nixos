{ config, pkgs, ... }: {
imports = [ ./hardware-configuration.nix ./hardware-overrides.nix ./conf/default.nix ];
nixpkgs.config = import ./conf/nixpkgs.nix;
_module.args.expr = import ./expr { inherit pkgs; };
}
