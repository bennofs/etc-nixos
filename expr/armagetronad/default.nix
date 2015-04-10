{stdenv, fetchbzr, boost, which, automake, autoconf, SDL2, SDL2_mixer, SDL2_image, libxml2, protobuf, mesa, ftgl, glew, pkgconfig, libpng, m4, yacc, python}:

stdenv.mkDerivation rec {
  name = "armagetronad-0.4-bzr-r${rev}";
  rev = "1566";
  src = fetchbzr {
    url = "lp:~armagetronad-dev/armagetronad/0.4-armagetronad-sdl2";
    inherit rev;
    sha256 = "0rj4yaixskyzka4i7mcpadpk36f3l5mvnzc9j8ss0mln99cxd463";
  };
  buildInputs = [stdenv boost which automake autoconf SDL2 SDL2_mixer SDL2_image libxml2 protobuf mesa ftgl glew pkgconfig libpng m4 yacc python];
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
