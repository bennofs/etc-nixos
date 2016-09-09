{ stdenv, bash, lock, python3, python3Packages }:

let
  pythonEnv = python3.buildEnv.override {
    extraLibs = with python3Packages; [ dbus-python pygobject3 mpd2 ];
  };
in stdenv.mkDerivation {
  name = "lock-on-suspend";
  inherit lock pythonEnv;
  buildCommand = ''
    mkdir -p $out/bin $out/libexec
    substituteAll ${./inhibitor.py} $out/bin/lock-on-suspend
    chmod +x $out/bin/lock-on-suspend
  '';
}
