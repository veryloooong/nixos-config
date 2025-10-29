{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "mi-sans";
  version = "1.0.0";

  src = ../assets/MiSans.7z;

  unpackPhase = ''
    runHook preUnpack
    ${pkgs.p7zip}/bin/7z x $src 
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    
    install -Dm644 *.otf -t $out/share/fonts/truetype

    runHook postInstall
  '';
}
