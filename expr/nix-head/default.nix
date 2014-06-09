{ stdenv, nix, fetchgit, autoconf, automake, libxml2, libxslt, docbook5, docbook5_xsl, flex, bison, tetex, dblatex, git, w3m }:

stdenv.lib.overrideDerivation nix (old: {
  src = fetchgit {
    url = https://github.com/NixOS/nix;
    sha256 = "ef09093e92a6fb4d9d2743b8ba1dab8f0c61e1cbb370459988e9135b7a3134c4";
  };
  buildInputs = old.buildInputs ++ [ autoconf automake libxml2 libxslt flex bison tetex dblatex git w3m ];
  preConfigure = "./bootstrap.sh";
  configureFlags = ''
    --with-docbook-rng=${docbook5}/xml/rng/docbook
    --with-docbook-xsl=${docbook5_xsl}/xml/xsl/docbook
  '' + old.configureFlags;
})