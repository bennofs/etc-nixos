{ stdenv, unzip, fetchurl, oraclejre7, bash }:

stdenv.mkDerivation rec {
  name = "softwarechallenge15-gui";
  src = fetchurl {
    url = "http://www.software-challenge.de/de/download/server-mit-grafischer-oberflaeche";
    sha256 = "159hfs8bsbl1kjx4c9gqiyr37qp5msdg8hjy6zkhbzdfxm90ligi";
  };

  buildInputs = [ unzip ];
  phases = [ "unpackPhase" "installPhase" "fixupPhase" ];

  unpackPhase = ''
    unzip $src
  '';

  installPhase = ''
    mkdir -p $out
    cp -r lib $out/
    cp -r plugins $out/
    cp softwarechallenge-gui.jar $out/

    mkdir $out/bin

    cat > $out/bin/softwarechallenge15-gui <<EOF
    #!${bash}/bin/bash
    mkdir -p \$HOME/.softwarechallenge/2015
    rm -rf \$HOME/.softwarechallenge/2015/replays
    for i in $out/${"*"}; do
      rm -rf     \$HOME/.softwarechallenge/2015/\''${i##*/}
      ln -sf \$i \$HOME/.softwarechallenge/2015/\''${i##*/}
    done

    cd \$HOME/.softwarechallenge/2015
    ${oraclejre7}/bin/java -jar ./softwarechallenge-gui.jar
    EOF

    chmod +x $out/bin/softwarechallenge15-gui
  '';

}