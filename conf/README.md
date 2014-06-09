nixconf
=======

This is the configuration of my NixOS system. I use it together with the following configuration.nix:

```
attrs: 
  let 
    config = import conf/default.nix (attrs // {
      expr = import ./expr { inherit (attrs) pkgs; };
    });
  in

config // {
  imports = config.imports ++ [ ./hardware-configuration.nix ];
}
```

This assumes that nixexpr and nixconf are checked out to the subdirectories expr and conf. 
