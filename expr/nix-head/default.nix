{ stdenv, nix, fetchgit, autoconf, automake, libxml2, libxslt, docbook5, docbook5_xsl, flex, bison, tetex, dblatex, git, w3m }:

stdenv.lib.overrideDerivation nix (old: {
  src = fetchgit {
    url = https://github.com/NixOS/nix;
    rev = "9d0709e8c47082cec35d6412053eacfadae23bcd";
    sha256 = "d5d09d08af782f9677c4e46d7393c16aa67cad5e6137bc37f680c3da6621405d";
  };
  buildInputs = old.buildInputs ++ [ autoconf automake libxml2 libxslt flex bison tetex dblatex git w3m ];
  preConfigure = "./bootstrap.sh";
  configureFlags = ''
    --with-docbook-rng=${docbook5}/xml/rng/docbook
    --with-docbook-xsl=${docbook5_xsl}/xml/xsl/docbook
  '' + old.configureFlags;
})