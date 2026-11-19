{ pkgs, lib, ... }:
let
  pname = "linuxviewer";
  version = "0.1.3";
  src = pkgs.fetchurl {
    url = "https://github.com/thehieucf/LinuxViewer/releases/download/v${version}/LinuxViewer-${version}-x86_64.AppImage";
    hash = "sha256-9gVytNsT05MnqhcuC0e3rcOHN2U8CWTVAkI8eHXaqTA=";
  };

  appimageContents = pkgs.appimageTools.extract { inherit pname version src; };
in
pkgs.appimageTools.wrapType2 rec {
  inherit pname version src;

  # AppImages assume host-distro libs NixOS does not provide at FHS paths.
  # libgpg-error is needed by bundled libgcrypt <- libssh-gcrypt <- webkit2gtk.
  extraPkgs = pkgs: [ pkgs.libgpg-error ];

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/io.github.linuxviewer.desktop -t $out/share/applications
    mkdir -p $out/share/icons
    cp -r ${appimageContents}/usr/share/icons/hicolor $out/share/icons/
    chmod -R u+w $out/share/icons/hicolor
  '';

  meta = {
    description = "UltraViewer-compatible remote desktop client (Rust + GTK4)";
    homepage = "https://github.com/thehieucf/LinuxViewer";
    downloadPage = "https://github.com/thehieucf/LinuxViewer/releases";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "linuxviewer";
    platforms = [ "x86_64-linux" ];
  };
}
