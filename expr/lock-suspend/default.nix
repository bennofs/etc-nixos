{ stdenv, bash, dbus_tools, systemd, lock, haskellPackages }:

let
  ghcEnv = haskellPackages.ghcWithPackages (hs: with hs; [
    turtle dbus libmpd
  ]);
in stdenv.mkDerivation {
  name = "lock-on-suspend";
  inherit lock;
  buildCommand = ''
    mkdir -p $out/bin $out/libexec
    substituteAll ${./inhibitor.hs} ./inhibitor.hs
    ${ghcEnv}/bin/ghc -o $out/libexec/lock-on-suspend.inhibit ./inhibitor.hs

    cat > $out/bin/lock-on-suspend <<EOF
    #!${bash}/bin/bash
    exec ${systemd}/bin/systemd-inhibit --what='sleep:handle-lid-switch' $out/libexec/lock-on-suspend.inhibit
    EOF
    chmod +x $out/bin/lock-on-suspend
  '';
}
