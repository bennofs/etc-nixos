{ stdenv, unzip, fetchurl, jre, bash }:

stdenv.mkDerivation rec {
  name = "softwarechallenge16-gui";
  src = fetchurl {
    url = "http://www.software-challenge.de/wp-content/uploads/2015/09/server-gui-java8.zip";
    sha256 = "0w6yaci44p3qbalpfaw14hvrxi40dvyv7a5n3895hwhzjgwynvbh";
  };

  buildInputs = [ unzip ];
  phases = [ "unpackPhase" "installPhase" "fixupPhase" ];

  unpackPhase = ''
    unzip $src
  '';

  installPhase = ''
    mkdir -p $out
    cp -r lib plugins $out/
    cp softwarechallenge-gui.jar $out/

    mkdir $out/bin

    cat > $out/bin/softwarechallenge16-gui <<EOF
    #!${bash}/bin/bash
    mkdir -p \$HOME/.softwarechallenge/2016

    cd \$HOME/.softwarechallenge/2016
    ${jre}/bin/java -jar $out/softwarechallenge-gui.jar -p $out/plugins "$@"
    EOF

    chmod +x $out/bin/softwarechallenge16-gui
  '';

}
