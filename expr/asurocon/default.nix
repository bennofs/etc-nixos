{ stdenv, fetchurl }:
stdenv.mkDerivation {
  name = "asurocon";
  src = fetchurl {
    url = "http://www.arexx.nl/downloads/asuro/asuro_flash_linux_source.zip";
    sha256 = "1lbpnpij2myzhgr0bsrmp19mpzpq22dwk8c1p4a8sxqmc9c3zr5f";
  };
  configurePhase = ":";
  buildPhase = ''
    cd con_flash
    echo "#include <string.h>" | cat - ./PosixSerial.cpp > x
    mv x ./PosixSerial.cpp
    g++ *.cpp -o asurocon -D_LINUX_ -D_CONSOLE -O2
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp ./asurocon $out/bin
  '';
}
