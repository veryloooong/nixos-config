{ pkgs, lib, ... }:
let
  pname = "limusic";
  version = "1.3.0";
  src = pkgs.fetchurl {
    url = "https://github.com/SimoHypers/limusic/releases/download/v${version}/limusic_${version}_amd64.AppImage";
    hash = "sha256-skhW7OeTMN06Y/WvI5Tm+Dja50rtxh42d0Q96Qwrc4c=";
  };

  appimageContents = pkgs.appimageTools.extract { inherit pname version src; };
in
pkgs.appimageTools.wrapType2 rec {
  inherit pname version src;

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/limusic.desktop -t $out/share/applications
    substituteInPlace $out/share/applications/limusic.desktop \
      --replace-fail 'Exec=limusic-app' 'Exec=${meta.mainProgram}' \
      --replace-fail 'Icon=limusic-app' 'Icon=${meta.mainProgram}'
    install -m 444 -D ${appimageContents}/limusic-app.png $out/share/pixmaps/${pname}.png
  '';

  meta = {
    description = "Feature rich, native desktop, YouTube Music client";
    homepage = "https://simohypers.github.io/limusic";
    downloadPage = "https://github.com/SimoHypers/limusic/releases";
    license = lib.licenses.gpl3Only;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "limusic";
    platforms = [ "x86_64-linux" ];
  };
}
