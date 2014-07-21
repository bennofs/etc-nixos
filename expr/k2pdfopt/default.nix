{ stdenv, requireFile }:

stdenv.mkDerivation {
  name = "k2pdfopt";
  src = requireFile {
    name = "k2pdfopt";
    url = "http://www.willus.com/k2pdfopt/download/";
    sha256 = "05pnchslwfy8hn5nnqgfl8f7fwpxd0xj6hybwamhrz5h0d6wdg8x"; # For 64bit linux
  };
  phases = ["installPhase"];
  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/k2pdfopt
    chmod +x $out/bin/k2pdfopt
  '';
}
