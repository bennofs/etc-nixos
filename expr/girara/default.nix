{ stdenv, ncurses, pkgconfig, fetchurl, gtk3, intltool, libnotify, gettext }:

stdenv.mkDerivation rec {
  name = "girara-${version}";
  version = "0.2.2";
  src = fetchurl {
    url = "http://pwmt.org/projects/girara/download/girara-${version}.tar.gz";
    sha256 = "0lv6wqhx2avdxj6yx111jfs4j32r0xzmmkhy7pgzxpf73kgxz0k3";
  };
  buildInputs = [ ncurses gtk3 intltool pkgconfig libnotify gettext ];
  makeFlags = "GIRARA_GTK_VERSION=3";
  installFlags = "PREFIX=$(out)";
}