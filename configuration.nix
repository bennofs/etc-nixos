attrs: 
  let 
    config = import conf/default.nix (attrs // {
      expr = import ./expr { inherit (attrs) pkgs; };
    });
  in

config // {
  imports = config.imports ++ [ ./hardware-configuration.nix ];
}
