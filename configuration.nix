{ config, pkgs, ... }: {
imports = [ ./hardware-configuration.nix ./hardware-overrides.nix ./conf/default.nix ./conf/accounts.nix ];
nixpkgs.config = import ./conf/nixpkgs.nix;
_module.args.expr = import ./expr { inherit pkgs; };
_module.args.buildVM = false;
}
