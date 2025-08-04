{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "microsoft-aptos";
  version = "4.4.0";

  src = ../assets/Microsoft-Aptos-Fonts.zip;

  unpackPhase = ''
    runHook preUnpack
    ${pkgs.unzip}/bin/unzip $src
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 *.ttf -t $out/share/fonts/truetype

    runHook postInstall
  '';
}
