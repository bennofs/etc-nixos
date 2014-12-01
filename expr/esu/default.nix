{ stdenv, fetchurl, jre, bash }:

stdenv.mkDerivation {
  name = "esu";
  src = fetchurl {
    url = "http://di188.di.informatik.tu-darmstadt.de/static/esu.jar";
    sha256 = "1xrvz0iqic11afchn009nnnvhic5xr8hnc2il32gi7pwm09fx5dg";
  };
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/bin $out/lib;
    cp $src $out/lib/esu.jar;
    cat > $out/bin/esu <<EOF
    #!${bash}/bin/bash
    export PATH="${jre}/bin:$PATH"
    java -jar $out/lib/esu.jar -- "$@"
    EOF
    chmod +x $out/bin/esu
  '';
}
