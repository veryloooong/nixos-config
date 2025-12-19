{
  config,
  pkgs,
  lib,
  options,
  ...
}:

let
  microsoft-aptos = pkgs.callPackage ./custom/aptos.nix { inherit pkgs; };
  mi-sans = import ./custom/mi-sans.nix { inherit pkgs; };
  sf-pro = import ./custom/sf-pro.nix { inherit pkgs; };

  capacities = import ./custom/capacities.nix { inherit pkgs lib; };
in
{
  # Enable flakes and the new Nix CLI
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.trusted-users = [
    "root"
    "veryloooong"
  ];

  nix.settings = {
    substituters = [
      "https://nix-gaming.cachix.org"
      "https://nix-community.cachix.org"
      "https://vicinae.cachix.org"
    ];
    trusted-public-keys = [
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
    ];
  };

  # Enable GC
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # Enable store optimisation
  nix.optimise.automatic = true;

  # Use latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Enable networking
  networking.networkmanager.enable = true;

  # Time and locale
  time.timeZone = "Asia/Ho_Chi_Minh";
  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # Enable fcitx5 to type Vietnamese and Mandarin
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-rime
      kdePackages.fcitx5-unikey
      fcitx5-bamboo
    ];
    fcitx5.waylandFrontend = true;
  };

  # Enable the X11 windowing system
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents
  services.printing.enable = true;

  # Enable sound with pipewire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager)
  services.libinput.enable = true;

  # shell
  programs.zsh.enable = true;
  environment.pathsToLink = [ "/share/zsh" ];

  # Define a user account. Don't forget to set a password with ‘passwd’
  users.users.veryloooong = {
    isNormalUser = true;
    description = "Hải Long";
    extraGroups = [
      "wheel"
      "libvirtd"
      "dialout"
    ]; # sudo access
    shell = pkgs.zsh;
    useDefaultShell = true;
    subUidRanges = [
      {
        startUid = 100000;
        count = 65536;
      }
    ];
    subGidRanges = [
      {
        startGid = 100000;
        count = 65536;
      }
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile
  environment.systemPackages = with pkgs; [
    # system
    file
    wget
    curl
    ripgrep
    wl-clipboard
    xsettingsd
    kdePackages.plasma-browser-integration
    kdePackages.filelight
    kdePackages.sddm-kcm

    # development
    git
    gnumake
    sccache

    # productivity
    chromium
    capacities
  ];

  # fonts
  # fonts.fontDir.enable = true;
  fonts.enableDefaultPackages = true;
  fonts.packages = with pkgs; [
    cascadia-code
    inter
    noto-fonts
    noto-fonts-color-emoji
    noto-fonts-cjk-sans
    corefonts
    microsoft-aptos
    mi-sans
    sf-pro
  ];

  # bindfs for theming
  system.fsPackages = [ pkgs.bindfs ];

  fileSystems =
    let
      mkRoSymBind = path: {
        device = path;
        fsType = "fuse.bindfs";
        options = [
          "ro"
          "resolve-symlinks"
          "x-gvfs-hide"
        ];
      };
      fontsPkgs = config.fonts.packages ++ [
        pkgs.kdePackages.breeze
        pkgs.kdePackages.oxygen
        pkgs.bibata-cursors
      ];
      x11Fonts =
        pkgs.runCommand "X11-fonts"
          {
            preferLocalBuild = true;
            nativeBuildInputs = with pkgs; [
              gzip
              xorg.mkfontscale
              xorg.mkfontdir
            ];
          }
          (
            ''
              mkdir -p "$out/share/fonts"
              font_regexp='.*\.\(ttf\|ttc\|otb\|otf\|pcf\|pfa\|pfb\|bdf\)\(\.gz\)?'
            ''
            + (builtins.concatStringsSep "\n" (
              builtins.map (pkg: ''
                find ${toString pkg} -regex "$font_regexp" \
                  -exec ln -sf -t "$out/share/fonts" '{}' \;
              '') fontsPkgs
            ))
            + ''
              cd "$out/share/fonts"
              mkfontscale
              mkfontdir
              cat $(find ${pkgs.xorg.fontalias}/ -name fonts.alias) >fonts.alias
            ''
          );
      aggregatedIcons = pkgs.buildEnv {
        name = "system-icons";
        paths = fontsPkgs;
        pathsToLink = [
          "/share/icons"
        ];
      };
    in
    {
      "/usr/share/icons" = mkRoSymBind (aggregatedIcons + "/share/icons");
      "/usr/share/fonts" = mkRoSymBind (x11Fonts + "/share/fonts");
    };

  # Make Neovim the default editor even though I use VSCode because VIM is some unc type shi
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # Enable nix-ld to run all binaries
  programs.nix-ld = {
    enable = true;
    libraries = options.programs.nix-ld.libraries.default ++ (with pkgs; [ ]);
  };

  # Enable flatpaks
  services.flatpak.enable = true;

  # Enable appimages
  programs.appimage.enable = true;
  programs.appimage.binfmt = true;

  # Enable portal
  xdg.portal = {
    enable = true;
    config = {
      common = {
        default = [
          "kde"
        ];
      };
    };
  };

  # EnvVars
  environment.variables = {
    EDITOR = "nvim";
    RUSTC_WRAPPER = "sccache";
  };

  # Enable the OpenSSH daemon
  services.openssh.enable = true;

  # Open ports in the firewall
  networking.firewall.allowedTCPPorts = [
    22 # SSH
    1883 # MQTT
  ];

  # mitmproxy cert
  security.pki.certificates = [ (builtins.readFile ./browser/mitmproxy-ca-cert.pem) ];

  # do not touch
  system.stateVersion = "25.11"; # Did you read the comment?
}
