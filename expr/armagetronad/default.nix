{stdenv, fetchbzr, boost, which, automake, autoconf, SDL, SDL_mixer, SDL_image, libxml2, protobuf, mesa, ftgl, glew, pkgconfig, libpng, m4, yacc, python}:

stdenv.mkDerivation rec {
  name = "armagetronad-0.4-bzr-r${rev}";
  rev = "1559";
  src = fetchbzr {
    url = "lp:armagetronad/0.4";
    inherit rev;
    sha256 = "1cnrh95y9hyyrzpkji640djvnyzg66svlfi6lg30jr8bra0q36g6";
  };
  buildInputs = [stdenv boost which automake autoconf SDL SDL_mixer SDL_image libxml2 protobuf mesa ftgl glew pkgconfig libpng m4 yacc python];
  patches = [ ./coler_auto_completion.patch ];
  patchFlags = "-p0";
  configureFlags = "--disable-games --disable-etc";
  preConfigure = ''
    ./bootstrap.sh
  '';
  preBuild = ''
    NIX_CFLAGS_COMPILE+="-O2 -march=native -ffast-math -msse4a -msse -mssse3 -msse2 -msse3"
  '';
}
