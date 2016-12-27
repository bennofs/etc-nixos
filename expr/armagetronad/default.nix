{stdenv, fetchbzr, gnugrep, boost, which, automake, autoconf, SDL, SDL_mixer, SDL_image, libxml2, protobuf, mesa, ftgl, glew, pkgconfig, libpng, m4, yacc, python, freetype}:

stdenv.mkDerivation rec {
  name = "armagetronad-0.4-bzr-r${rev}";
  rev = "1608";
  src = fetchbzr {
    url = "lp:armagetronad/0.4";
    inherit rev;
    sha256 = "1xwlay3l51nc9mc4d7kbpmi754i36gm0cx706mdg1gnajsdpjp8b";
  };
  buildInputs = [gnugrep stdenv boost which automake autoconf SDL SDL_mixer SDL_image libxml2 protobuf mesa ftgl glew pkgconfig libpng m4 yacc python freetype];
  patchFlags = "-p0";
  configureFlags = "--disable-games --disable-etc";
  preConfigure = ''
    ./bootstrap.sh
  '';
  preBuild = ''
    NIX_CFLAGS_COMPILE+="-O2 -march=native -ffast-math -msse4a -msse -mssse3 -msse2 -msse3"
  '';
}
