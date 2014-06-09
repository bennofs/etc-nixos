{ stdenv, nix, fetchgit }:

stdenv.lib.overrideDerivation nix (old: {
  src = fetchgit {
    url = https://github.com/NixOS/nix;
    sha256 = "ef09093e92a6fb4d9d2743b8ba1dab8f0c61e1cbb370459988e9135b7a3134c4";
  };
})