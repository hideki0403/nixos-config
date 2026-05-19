{
  lib,
  stdenvNoCC,
  fetchurl,
  p7zip,
}:

stdenvNoCC.mkDerivation rec {
  pname = "genjyuugothic-l";
  version = "20150607";

  src = fetchurl {
    url = "https://ftp.iij.ad.jp/pub/osdn.jp/users/8/8635/${pname}-${version}.7z";
    hash = "sha256-aYAHpXg+l+ghuSnQ5X90RGqG3s5QMv5XaJc1ZYb3bLs=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ p7zip ];

  installPhase = ''
    runHook preInstall

    install -m 444 -D -t $out/share/fonts/${pname} *.ttf

    runHook postInstall
  '';

  meta = {
    description = "genjyuu gothic";
    homepage = "http://jikasei.me/font/genjyuu/";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ me ];
  };
}
