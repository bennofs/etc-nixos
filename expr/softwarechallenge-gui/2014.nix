{ stdenv, unzip, fetchurl, oraclejre7, bash, coreutils }:

stdenv.mkDerivation rec {
  name = "softwarechallenge14-gui";
  src = fetchurl {
    url = "http://www.informatik.uni-kiel.de/fileadmin/zentrale_bereiche/software_challenge/2014/downloads/server-gui.zip";
    sha256 = "101i5959jgx59irmb4m7ggwpnxchhhflckvjqrvgzhxxkvgf18d7";
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

    cat > $out/bin/softwarechallenge14-gui <<EOF
    #!${bash}/bin/bash
    mkdir -p \$HOME/.softwarechallenge/2014
    rm -rf \$HOME/.softwarechallenge/2014/replays
    for i in $out/${"*"}; do
      rm -rf     \$HOME/.softwarechallenge/2014/\''${i##*/}
      ln -sf \$i \$HOME/.softwarechallenge/2014/\''${i##*/}
    done
      
    cd \$HOME/.softwarechallenge/2014
    ${oraclejre7}/bin/java -jar ./softwarechallenge-gui.jar
    EOF

    chmod +x $out/bin/softwarechallenge14-gui
  '';

}