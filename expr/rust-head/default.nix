{ stdenv, fetchgit, fetchurl, which, file, perl, curl, python27 }:

let

  snapshot = stdenv.mkDerivation rec {
    name = "rust-stage0";
    date = "2014-07-09";
    rev = "8ddd286";
    src = fetchurl rec {
      url = "http://static.rust-lang.org/stage0-snapshots/rust-stage0-${date}-${rev}-linux-x86_64-${sha1}.tar.bz2";
      sha1 = "853bd73501a10d49cafdf823110c61f13a3392d6";
    };
    dontStrip = true;
    installPhase = ''
      mkdir -p "$out"
      cp -r bin "$out/bin"
    '' + (if stdenv.isLinux then ''
      patchelf --interpreter "${stdenv.glibc}/lib/${stdenv.gcc.dynamicLinker}" \
               --set-rpath "${stdenv.gcc.gcc}/lib/:${stdenv.gcc.gcc}/lib64/" \
               "$out/bin/rustc"
    '' else "");
  };

in

stdenv.mkDerivation {
  name = "rust-1.12git";
  src = fetchgit {
    url = "http://github.com/rust-lang/rust";
    rev = "55cf6d723c40bf720d7d9f9ed3a5833caa8faf1a";
    sha256 = "90ad3308d29026a5ff30837fb32d51959886f5d96cd506c32ab79845915dc52c";
    fetchSubmodules = true;
  };

  patches = [ ./local_stage0.patch ];
  prePatch = ''
    sed -i -e 's/"ar"/"@arPath@"/' -e 's/"cc"/"@ccPath@"/' src/librustc/back/link.rs
    substituteInPlace src/librustc/back/link.rs \
      --subst-var-by "ccPath" "${stdenv.gcc}/bin/cc" \
      --subst-var-by "arPath" "${stdenv.gcc.binutils}/bin/ar"
  '';

  buildInputs = [ which file perl curl python27 ];
  configureFlags = [ "--enable-local-rust" "--local-rust-root=${snapshot}" ];
  enableParallelBuilding = true;

}
