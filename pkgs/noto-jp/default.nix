{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation {
  pname = "noto-fonts-jp";
  version = "2.004";

  src = fetchFromGitHub {
    owner = "notofonts";
    repo = "noto-cjk";
    rev = "f8d157532fbfaeda587e826d4cd5b21a49186f7c";
    hash = "sha256-mJ+I+Y9cn4j3OCD0G4EUXoCNi8EN389b/VaS7hbW3l0=";
    sparseCheckout = [
      "Sans/OTF/Japanese"
      "Serif/OTF/Japanese"
    ];
  };

  installPhase = ''
    install -m 444 -D -t $out/share/fonts/opentype/noto-sans-jp Sans/OTF/Japanese/*.otf
    install -m 444 -D -t $out/share/fonts/opentype/noto-serif-jp Serif/OTF/Japanese/*.otf
  '';

  meta = {
    description = "Noto JP";
    homepage = "https://www.google.com/get/noto/help/cjk/";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ me ];
  };
}
