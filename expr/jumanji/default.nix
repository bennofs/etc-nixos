{ stdenv, fetchgit, makeWrapper, pkgconfig, libsoup, webkitgtk, girara, gtk3, glib_networking, gsettings_desktop_schemas }:

stdenv.mkDerivation {
  name = "jumanij";
  src = fetchgit {
    url = "git://pwmt.org/jumanji.git";
    rev = "8f40487304a6a931487c411b25001f2bb5cf8d4f";
    sha256 = "dbc67947e005259bdee9e5a89c667b64c0dd0269c712fbbb9d627baf7202b3c1";
  };
  buildInputs = [ pkgconfig libsoup webkitgtk girara gtk3 makeWrapper gsettings_desktop_schemas ];
  makeFlags = "PREFIX=$(out)";
  preFixup = ''
    wrapProgram "$out/bin/jumanji" \
      --prefix GIO_EXTRA_MODULES : "${glib_networking}/lib/gio/modules" \
      --prefix XDG_DATA_DIRS : "$GSETTINGS_SCHEMAS_PATH:$out/share"
  '';
  inherit girara;
}
