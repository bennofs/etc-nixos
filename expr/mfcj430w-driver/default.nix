{ stdenv, fetchurl, writeScriptBin, dpkg, findutils, patchelf, file, makeWrapper, psnup, coreutils, which, ghostscript }:

let
  model = "mfcj430w";
  stubScript = name: "${writeScriptBin name ''echo "${name}: skipping"''}/bin";
  a2ps = stubScript "a2ps";
in

stdenv.mkDerivation {
  name = "brother-mfcj430w";
  srcs = [
    (fetchurl {
      url = "http://www.brother.com/pub/bsc/linux/dlf/${model}lpr-3.0.1-1.i386.deb";
      sha256 = "1sfmca4piqq5b0czmbgbh48jnqbqv72dlhl7c0cczhgzmr3zqbbv";
    })
    (fetchurl {
      url = "http://www.brother.com/pub/bsc/linux/dlf/${model}cupswrapper-3.0.0-1.i386.deb";
      sha256 = "19an84ziakrjnmi934l0pg9l28hwzq59k252xss9nida1m6qb87q";
    })
  ];
  phases = ["installPhase" "fixupPhase"];
  buildInputs = [ dpkg findutils patchelf file makeWrapper ];

  installPhase = ''
    echo ":: Preparing environment and files"
    export PATH="$PATH:${stubScript "lpadmin"}:${stubScript "lpinfo"}"
    for s in $srcs; do dpkg-deb -x $s $out; done
    mv $out/usr/* $out
    rmdir $out/usr
    mkdir -p $out/lib/cups/filter

    echo -e "\n:: Patching scripts"
    find $out -type f -executable -exec grep -Iq . {} \; -and -not -name "*.ppd" -and -print | while read file; do
      echo "Patching script $file ..."
      substituteInPlace "$file" \
        --replace "/opt" "$out/opt" \
        --replace /usr "$out" \
        --replace /etc "$out/etc" \
        --replace /var/tmp "$TMPDIR" \
        --replace "share/ppd" "share/cups/model"
    done
    patchShebangs $out

    echo -e "\n:: Installing cupswrapper"
    chmod +x $out/opt/brother/Printers/${model}/cupswrapper/cupswrapper${model}
    $out/opt/brother/Printers/${model}/cupswrapper/cupswrapper${model}

    echo -e "\n:: Patching binary files"
    find $out -type f -executable -exec file -i '{}' \; | grep 'x-executable; charset=binary' | while read file; do
      file="''${file%%:*}"
      echo "Patching executable $file ..."
      patchelf --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $file
    done


    wrapProgram "$out/lib/cups/filter/brother_lpdwrapper_${model}" \
      --prefix PATH ":" "${psnup}/bin"
    wrapProgram "$out/opt/brother/Printers/${model}/lpd/filter${model}" \
      --prefix PATH ":" "${file}/bin:${a2ps}/bin"
    wrapProgram "$out/opt/brother/Printers/${model}/lpd/psconvertij2" \
      --prefix PATH ":" "${which}/bin:${a2ps}/bin"

    echo -e "\n:: Cleanup"
    cd "$out/opt/brother/Printers/${model}"
    rm cupswrapper/*.ppd "cupswrapper/cupswrapper${model}"
    rm inf/setupPrintcapij

    echo -e "\n:: Done"
  '';
}
