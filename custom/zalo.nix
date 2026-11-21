{ pkgs, lib, ... }:
let
  pname = "zalo";
  version = "26.11.10";
  mainProgram = "zalo";
  # ZaDark variant (the project's default flavour; swap "+ZaDark-26.3-836500e"
  # for "-Original-836500e" in the URL if the plain client is preferred).
  src = pkgs.fetchurl {
    url = "https://github.com/VN-Linux-Family/zalo-for-linux/releases/download/${version}/Zalo-${version}%2BZaDark-26.3-836500e-x86_64.AppImage";
    hash = "sha256-6y39QRnxT7+dWZCjB4snaWcgMqBwGH2eDCyiBXg5GRY=";
  };

  # This AppImage embeds a DWARFS payload (quick-sharun build), not squashfs —
  # appimageTools.extract cannot read it. Extract with the dwarfs tools instead.
  # The payload offset comes from `${src} --appimage-offset`.
  dwarfsTools = pkgs.dwarfs.overrideAttrs (old: {
    # upstream 0.15.8's bundled test suite is broken (dwarfsextract_format_test
    # aborts) and -DWITH_TESTS=ON pulls the ricepp dep via network FetchContent,
    # which fails in the sandbox — so build the tools with tests off.
    doCheck = false;
    cmakeFlags = (old.cmakeFlags or [ ]) ++ [ "-DWITH_TESTS=OFF" ];
  });
  contents = pkgs.stdenvNoCC.mkDerivation {
    pname = "${pname}-extracted";
    inherit version;
    nativeBuildInputs = [ dwarfsTools ];
    buildCommand = ''
      mkdir -p $out
      dwarfsextract -i ${src} -o $out -O 1504648
    '';
  };

  fhs = pkgs.appimageTools.wrapAppImage {
    inherit pname version;
    inherit contents;
    extraPkgs = pkgs: [
      pkgs.libgpg-error # bundled libgcrypt <- libssh-gcrypt <- electron updater
      pkgs.libopus # call engine
      pkgs.python3 # call engine
      pkgs.pulseaudio # pactl/pacat for calls
    ];
  };
in
pkgs.runCommand pname
  {
    meta = {
      description = "Unofficial Zalo desktop client for Linux (Electron, with ZaDark)";
      homepage = "https://github.com/VN-Linux-Family/zalo-for-linux";
      downloadPage = "https://github.com/VN-Linux-Family/zalo-for-linux/releases";
      license = lib.licenses.mit;
      sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
      mainProgram = mainProgram;
      platforms = [ "x86_64-linux" ];
    };
  }
  ''
    mkdir -p $out/bin $out/share/applications $out/share/icons/hicolor $out/share/pixmaps
    ln -s ${fhs}/bin/${pname} $out/bin/${pname}
    desktop=$(find ${contents} -maxdepth 1 -name '*.desktop' | head -1)
    install -m 444 "$desktop" $out/share/applications/${pname}.desktop
    if [ -d ${contents}/usr/share/icons/hicolor ]; then
      cp -r ${contents}/usr/share/icons/hicolor/* $out/share/icons/hicolor/
    fi
    if [ -d ${contents}/usr/share/pixmaps ]; then
      cp -r ${contents}/usr/share/pixmaps/* $out/share/pixmaps/
    fi
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=${mainProgram}' || true
  ''
