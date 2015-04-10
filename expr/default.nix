{ pkgs ? import <nixpkgs> {} }: with pkgs;

rec {

softwarechallenge14-gui = callPackage ./softwarechallenge-gui/2014.nix {};

softwarechallenge15-gui = callPackage ./softwarechallenge-gui/2015.nix {
  jre = oraclejre8;
};

esu = callPackage ./esu {};

SDL2_wayland = SDL2.overrideDerivation (old: {
  nativeBuildInputs = old.nativeBuildInputs ++ [ wayland libxkbcommon ];
  configureFlags = old.configureFlags + '' --enable-video-wayland '';
});

armagetronad = callPackage ./armagetronad {
  SDL2 = SDL2_wayland;
  SDL2_mixer = SDL2_mixer.override { SDL2 = SDL2_wayland; };
  SDL2_image = SDL2_image.override { SDL2 = SDL2_wayland; };
};

rustHead = callPackage ./rust-head {};

nixos-sync = nixos-rebuild: callPackage ./nixos-sync {
  git = gitMinimal;
  inherit nixos-rebuild;
};

asurocon = callPackage ./asurocon {};

}
