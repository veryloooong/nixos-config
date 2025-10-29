{ pkgs, lib, ... }: 
let
  pname = "capacities";
  version = "1.54.17";
  src = pkgs.fetchurl {
    url = "https://capacities-desktop-app.fra1.cdn.digitaloceanspaces.com/Capacities-${version}.AppImage";
    hash = "sha256-5A+LrTX1pMSxJXX/I7gQGyZvZhf4Qb5M0sZnEcuP2EQ=";
  };

  appimageContents = pkgs.appimageTools.extractType1 { inherit pname version src; };
in pkgs.appimageTools.wrapType2 rec {
  inherit pname version src;

  extraBwrapArgs = [
    "--bind-try /etc/nixos/ /etc/nixos/"
  ];

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/${pname}.desktop -t $out/share/applications
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=${meta.mainProgram}'
    cp -r ${appimageContents}/usr/share/icons $out/share
  '';

  meta = {
    description = "Object-based note-taking app";
    homepage = "https://capacities.io/";
    downloadPage = "https://capacities.io/download-app";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "capacities";
    platforms = [ "x86_64-linux" ];
  };
}
