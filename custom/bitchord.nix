{ pkgs, lib, ... }:
let
  pname = "bitchord";
  version = "1.8";
  src = pkgs.fetchurl {
    url = "https://github.com/kushagrasinghx/BitChord/releases/download/v${version}/BitChord-${version}-linux-x86_64.AppImage";
    hash = "sha256-WSZiB8ar3ba0u76FcM1pwTd/So9eWMJLloJPZY9GUbg=";
  };

  appimageContents = pkgs.appimageTools.extract { inherit pname version src; };
in
pkgs.appimageTools.wrapType2 rec {
  inherit pname version src;

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/${pname}.desktop -t $out/share/applications
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace-fail 'Exec=BitChord' 'Exec=${meta.mainProgram}'
    install -m 444 -D ${appimageContents}/${pname}.png $out/share/pixmaps/${pname}.png
  '';

  meta = {
    description = "Aesthetic YouTube Music client";
    homepage = "https://bitchord.kushagrasingh.in/";
    downloadPage = "https://github.com/kushagrasinghx/BitChord/releases";
    license = lib.licenses.gpl3Only;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "bitchord";
    platforms = [ "x86_64-linux" ];
  };
}
