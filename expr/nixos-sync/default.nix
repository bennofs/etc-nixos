{ stdenv, git, coreutils, less, gnused, gnugrep, systemd, nixos-rebuild }:

stdenv.mkDerivation {
  name = "nixos-sync";
  buildCommand = ''
    cat >$out <<EOF
    #!${stdenv.shell}
    export PATH=/var/setuid-wrappers:${coreutils}/bin:${gnugrep}/bin:${systemd}/bin:${gnused}/bin:${less}/bin:${git}/bin:${nixos-rebuild}/bin
    exec ${stdenv.shell} ${./nixos-sync.sh} "\$@"
    EOF
    chmod +x $out
  '';
}
