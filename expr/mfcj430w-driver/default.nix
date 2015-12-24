{ stdenv, fetchurl, writeScriptBin, dpkg, findutils, patchelf, file, makeWrapper, psnup, coreutils }:

let
  model = "mfcj430w";
  stubScript = name: "${writeScriptBin name ""}/bin";
in

stdenv.mkDerivation {
  name = "brother-mfcj430w";
  srcs = [
    (fetchurl {
      url = "http://www.brother.com/pub/bsc/linux/dlf/${model}lpr-3.0.1-1.i386.deb";
      sha256 = "1sfmca4piqq5b0czmbgbh48jnqbqv72dlhl7c0cczhgzmr3zqbbv";
    })
    (fetchurl {
      url = "http://www.brother.com/pub/bsc/linux/dlf/mfcj430wcupswrapper-3.0.0-1.i386.deb";
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
    mkdir -p $out/var/tmp $out/lib/cups/filter

    echo -e "\n:: Patching sources"
    substituteInPlace $out/opt/brother/Printers/${model}/cupswrapper/cupswrapper${model} \
      --replace /opt "$out/opt" \
      --replace /usr "$out" \
      --replace /etc "$out/etc" \
      --replace /var "$out/var" \
      --replace "share/ppd" "share/cups/model"
    patchShebangs $out

    echo -e "\n:: Installing cupswrapper"
    chmod +x $out/opt/brother/Printers/${model}/cupswrapper/cupswrapper${model}
    $out/opt/brother/Printers/${model}/cupswrapper/cupswrapper${model}

    echo -e "\n:: Patching binary files"
    find $out -type f -executable -exec file -i '{}' \; | grep 'x-executable; charset=binary' | while read file; do
      file="''${file%%:*}"
      echo "Patching $file..."
      patchelf --interpreter "${stdenv.cc.dynamicLinker}" $file
    done

    echo -e "\n:: Patching scripts"
    substituteInPlace "$out/lib/cups/filter/brother_lpdwrapper_${model}" \
      --replace "LOGFILE=\"/dev/null\"" "LOGFILE=/tmp/printlog" \
      --replace "LOGLEVEL=\"1\"" "LOGLEVEL=9"
    wrapProgram "$out/lib/cups/filter/brother_lpdwrapper_${model}" \
      --prefix PATH ":" "${psnup}/bin:${coreutils}/bin"

    echo -e "\n:: Done"
  '';
}
