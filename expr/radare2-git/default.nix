{ radare2, capstone, fetchFromGitHub }:

radare2.overrideAttrs (old: {
  buildInputs = old.buildInputs ++ [ capstone ];
  configureFlags = [ "--with-syscapstone"];
  hardeningDisable = [ "format" ];
  src = fetchFromGitHub {
    owner = "radare";
    repo = "radare2";
    rev = "f36cd87cb1547e47e82eaf51e5e3c44553a074ea";
    sha256 = "1sbz4x8wz6s95bcq4xgr0g4qvryyvhfny0v8g75brnjmkc2gqxrr";
  };
})
