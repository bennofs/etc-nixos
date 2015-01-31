{ stdenv, unzip, fetchurl, jre, bash }:

stdenv.mkDerivation rec {
  name = "softwarechallenge15-gui";
  src = fetchurl {
    url = "http://www.software-challenge.de/de/download/der-server-mit-grafischer-oberflaeche-fuer-java-8";
    sha256 = "0pn88gnn6vhzrpjr2kc2lv0wv6am11rqmrsa0x7rwi6dz6c5gzvg";
  };

  buildInputs = [ unzip ];
  phases = [ "unpackPhase" "installPhase" "fixupPhase" ];

  unpackPhase = ''
    unzip $src
  '';

  installPhase = ''
    mkdir -p $out $out/plugins
    cp -r lib $out/
    cp ${./plugin2015.jar} $out/plugins
    cp softwarechallenge-gui.jar $out/

    mkdir $out/bin

    cat > $out/bin/softwarechallenge15-gui <<EOF
    #!${bash}/bin/bash
    mkdir -p \$HOME/.softwarechallenge/2015

    cd \$HOME/.softwarechallenge/2015
    ${jre}/bin/java -jar $out/softwarechallenge-gui.jar -p "$out/plugins" "$@"
    EOF

    chmod +x $out/bin/softwarechallenge15-gui
  '';

}
