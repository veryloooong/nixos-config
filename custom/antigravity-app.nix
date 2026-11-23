{ pkgs, lib, ... }:
let
  pname = "antigravity-app";
  version = "2.34.0";
  buildId = "5887025308631040";
  src = pkgs.fetchurl {
    url = "https://storage.googleapis.com/antigravity-public/antigravity-hub/${version}-${buildId}/linux-x64/Antigravity.tar.gz";
    hash = "sha256-R4xo+Gye9hpQIYWjnpzuxmsSdqalOxkaGbDZzoaYNts=";
  };
  icon = pkgs.fetchurl {
    url = "https://antigravity.google/apple-touch-icon.png";
    hash = "sha256-ROIZn2Xi1m+4E03i8o2gIEIHYPWd6Ly0VXNlE2yziyQ=";
  };

  # Unpack: tarball contains Antigravity-x64/ with the Electron app at its root.
  app = pkgs.stdenvNoCC.mkDerivation {
    pname = "${pname}-unpacked";
    inherit version src;
    buildCommand = ''
      mkdir -p $out/share/antigravity
      tar xzf ${src} -C $out/share/antigravity
      mv $out/share/antigravity/Antigravity-x64/* $out/share/antigravity/
      rmdir $out/share/antigravity/Antigravity-x64
      chmod +x $out/share/antigravity/antigravity
    '';
  };

  # Electron binary expects a standard FHS library layout; wrap it instead of
  # auto-patching so Chrome's own ELF deps keep working untouched.
  fhs = pkgs.buildFHSEnv {
    pname = pname;
    version = version;
    targetPkgs = pkgs: with pkgs; [
      gtk3
      glib
      cairo
      pango
      gdk-pixbuf
      nss
      nspr
      cups
      dbus
      libdrm
      libgbm
      libxkbcommon
      wayland
      expat
      alsa-lib
      pulseaudio
      udev
      xdg-utils
      zlib
      fontconfig
      freetype
      at-spi2-atk
      at-spi2-core
      xorg.libX11
      xorg.libxcb
      xorg.libXcomposite
      xorg.libXdamage
      xorg.libXext
      xorg.libXfixes
      xorg.libXrandr
    ];
    # --no-sandbox is required on NixOS: chrome-sandbox needs setuid, which the
    # store cannot provide. ELECTRON_OZONE_PLATFORM_HINT=auto runs it natively
    # on Wayland so it follows the compositor scale (HiDPI) correctly.
    # --force-device-scale-factor=1 pins the UI at 100% — the user prefers the
    # app smaller than the 2x display scale.
    runScript = pkgs.writeShellScript "${pname}-wrapper" ''
      export ELECTRON_OZONE_PLATFORM_HINT=auto
      exec ${app}/share/antigravity/antigravity --no-sandbox --force-device-scale-factor=1 "$@"
    '';
  };
in
pkgs.runCommand pname
  {
    meta = {
      description = "Google Antigravity standalone desktop app (agent command center)";
      homepage = "https://antigravity.google";
      sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
      mainProgram = pname;
      platforms = [ "x86_64-linux" ];
    };
  }
  ''
    mkdir -p $out/bin $out/share/applications $out/share/icons/hicolor/180x180/apps
    ln -s ${fhs}/bin/${pname} $out/bin/antigravity
    install -m 444 ${icon} $out/share/icons/hicolor/180x180/apps/${pname}.png

    cat > $out/share/applications/${pname}.desktop <<'EOF'
    [Desktop Entry]
    Type=Application
    Name=Antigravity
    Comment=Google Antigravity desktop app
    Exec=env ELECTRON_OZONE_PLATFORM_HINT=auto antigravity --no-sandbox --force-device-scale-factor=1 %U
    Icon=antigravity-app
    Terminal=false
    Categories=Development;
    EOF
  ''
