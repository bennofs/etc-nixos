{ stdenv, nix, fetchgit, autoconf, automake, libxml2, libxslt, docbook5, docbook5_xsl, flex, bison, tetex, dblatex, git, w3m }:
stdenv.lib.overrideDerivation nix (old: {
  src = fetchgit {
    url = https://github.com/NixOS/nix;
    rev = "e82951fe23daa961ef18b0c5cc9ba1f5d8906186";
    sha256 = "b36c5316bbddb83ba1a41914a955e7abbdbbafd79f46266f982ba94e4295724f";
  };
  buildInputs = old.buildInputs ++ [ autoconf automake libxml2 libxslt flex bison tetex dblatex git w3m ];
  preConfigure = "./bootstrap.sh";
  configureFlags = ''
    --with-docbook-rng=${docbook5}/xml/rng/docbook
    --with-docbook-xsl=${docbook5_xsl}/xml/xsl/docbook
  '' + old.configureFlags;
})
