{stdenv, fetchbzr, boost, which, automake, autoconf, SDL, SDL_mixer, SDL_image, libxml2, protobuf, mesa, ftgl, glew, pkgconfig, libpng, m4, yacc, python}:

stdenv.mkDerivation rec {
  name = "armagetronad-0.4-bzr-r${rev}";
  rev = "1587";
  src = fetchbzr {
    url = "lp:armagetronad/0.4";
    inherit rev;
    sha256 = "0hba1mg0rv9mnnahf6ks6d20v0801ass3r1vvijfmpf0sl0s8z7g";
  };
  buildInputs = [stdenv boost which automake autoconf SDL SDL_mixer SDL_image libxml2 protobuf mesa ftgl glew pkgconfig libpng m4 yacc python];
  patchFlags = "-p0";
  configureFlags = "--disable-games --disable-etc";
  preConfigure = ''
    ./bootstrap.sh
  '';
  preBuild = ''
    NIX_CFLAGS_COMPILE+="-O2 -march=native -ffast-math -msse4a -msse -mssse3 -msse2 -msse3"
  '';
}
