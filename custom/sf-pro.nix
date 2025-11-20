{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "sf-pro";
  version = "1.0.0";

  src = ../assets/sf-pro.7z;

  unpackPhase = ''
    runHook preUnpack
    ${pkgs.p7zip}/bin/7z x $src 
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 *.otf -t $out/share/fonts/opentype

    runHook postInstall
  '';
}
