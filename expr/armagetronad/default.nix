{stdenv, fetchbzr, boost, which, automake, autoconf, SDL, SDL_mixer, SDL_image, libxml2, protobuf, mesa, ftgl, glew, pkgconfig, libpng, m4, yacc, python}:

stdenv.mkDerivation rec {
  name = "armagetronad-0.4-bzr-r${rev}";
  rev = "1580";
  src = fetchbzr {
    url = "lp:armagetronad/0.4";
    inherit rev;
    sha256 = "0pkxg48p9jr24li6rmbm3kn3dl2ldha94sxc8xa4zivalcr0dy0q";
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
