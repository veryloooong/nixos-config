flake-overlays:

{
  config,
  pkgs,
  lib,
  options,
  inputs,
  system ? pkgs.system,
  ...
}:

let
  microsoft-aptos = pkgs.callPackage ./custom/aptos.nix { inherit pkgs; };
  mi-sans = import ./custom/mi-sans.nix { inherit pkgs; };
  sf-pro = import ./custom/sf-pro.nix { inherit pkgs; };
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration-laptop.nix
  ];

  # Overlays: keep this order — the module system sorts by file path, so
  # configuration-common evaluated BEFORE configuration-laptop pre-merge.
  nixpkgs.overlays = [
    (final: prev: {
      openldap = prev.openldap.overrideAttrs (oldAttrs: {
        doCheck = false;
      });
    })
    (
      final: prev: {
        # Your own overlays...
      }
    )
  ] ++ flake-overlays;

  # Nix
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
    cores = 4;
    max-jobs = 4;
  };

  # Enable GC
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # Enable store optimisation
  nix.optimise.automatic = true;

  # Bootloader and boot screen
  # boot.loader.systemd-boot.enable = true;

  boot.loader.systemd-boot.enable = lib.mkForce false;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  boot.loader.efi.canTouchEfiVariables = true;
  boot.plymouth.enable = true;

  # Use latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # SysRq
  boot.kernel.sysctl."kernel.sysrq" = 502;

  # swap fix
  boot.resumeDevice = "/dev/disk/by-label/swap"; # Replace with your actual swap UUID

  # Firmware/hardware stuff
  hardware.cpu.amd.updateMicrocode = true;
  services.fwupd.enable = true;

  hardware.amdgpu.opencl.enable = true;

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  networking.hostName = "lebobo"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  services.cloudflare-warp.enable = true;

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
      fcitx5-lotus
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
    linger = true;
    description = "Hải Long";
    # Order preserved from the pre-merge modules (configuration-common sorted
    # before configuration-laptop).
    extraGroups = [
      "wheel"
      "libvirtd"
      "dialout"
      "podman"
      "kvm"
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
  users.extraGroups.vboxusers.members = [ "veryloooong" ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  # (AI) Suppress fatal evaluation errors for deprecated/broken packages (gtk+ for Lutris FHS, libguestfs for Vagrant)
  nixpkgs.config.problems.handlers = {
    "gtk+".broken = "warn";
    libguestfs.broken = "warn";
  };

  # List packages installed in system profile.
  # Element order preserved from the pre-merge modules (configuration-common
  # sorted before configuration-laptop).
  environment.systemPackages = with pkgs; [
    # system
    file
    p7zip
    wget
    curl
    helix
    ripgrep
    wl-clipboard
    xsettingsd
    kdePackages.plasma-browser-integration
    kdePackages.plasma-workspace
    kdePackages.filelight
    kdePackages.sddm-kcm

    # development
    git
    gnumake

    # productivity
    chromium

    # development (laptop)
    cmake

    # secure boot
    sbctl

    # Gaming (laptop)
    protonup-qt
    (heroic.override {
      extraPkgs = pkgs: [
        pkgs.gamescope
        pkgs.gamemode
      ];
    })

    # utility
    pocl

    # KDE (laptop)
    kdePackages.kup # Backup
    kdePackages.kamoso # Camera
    kdePackages.kcalc # Calculator
    kdePackages.qtstyleplugin-kvantum
    kdePackages.krdp

    # Virtualisation
    fuse-overlayfs
    podman-compose
    crun
    vagrant
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
              mkfontscale
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
              cat $(find ${pkgs.font-alias}/ -name fonts.alias) >fonts.alias
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
  # programs.neovim = {
  #   enable = true;
  #   defaultEditor = true;
  #   viAlias = true;
  #   vimAlias = true;
  # };

  # Enable nix-ld to run all binaries
  programs.nix-ld = {
    enable = true;
    libraries = options.programs.nix-ld.libraries.default ++ (with pkgs; [
      libxcrypt
      libxcrypt-legacy
      coreutils
      libgpg-error
      libgcrypt
    ]);
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
    EDITOR = "hx";

    # Claude Code → DeepSeek's Anthropic-compatible API
    ANTHROPIC_BASE_URL = "https://api.deepseek.com/anthropic";
    ANTHROPIC_MODEL = "deepseek-v4-flash[1m]";
    ANTHROPIC_DEFAULT_OPUS_MODEL = "deepseek-v4-pro[1m]";
    ANTHROPIC_DEFAULT_SONNET_MODEL = "deepseek-v4-flash[1m]";
    ANTHROPIC_DEFAULT_HAIKU_MODEL = "deepseek-v4-flash";
    CLAUDE_CODE_SUBAGENT_MODEL = "deepseek-v4-flash";

    # devenv
    DEVENV_MAX_JOBS = 2;
    DEVENV_CORES = 4;
  };

  # Enable the OpenSSH daemon
  services.openssh.enable = true;

  # Enable Tailscale
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
  };

  # Open ports in the firewall
  networking.nftables.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 3389 49374 ];
    allowedUDPPorts = [ 3389 49374 ];
    trustedInterfaces = [
      "Mihomo"
    ];
    extraReversePathFilterRules = ''iifname { "Mihomo" } accept comment "trusted interface"'';
  };

  # mitmproxy cert
  security.pki.certificates = [ (builtins.readFile ./browser/mitmproxy-ca-cert.pem) ];

  # KDE Connect
  programs.kdeconnect.enable = true;

  # Battery and power management
  services.power-profiles-daemon.enable = false;
  services.auto-cpufreq = {
    enable = true;
    settings = {
      charger = {
        governor = "performance";
        energy_performance_preference = "performance";
        platform_profile = "performance";
        turbo = "auto";
      };
      battery = {
        governor = "powersave";
        energy_performance_preference = "balance_power";
        platform_profile = "low-power";
        scaling_max_freq = 3200000;
        turbo = "never";
      };
    };
  };

  # Gaming
  programs.gamescope.enable = true;
  programs.gamemode.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
  };

  # Virtualisation
  virtualisation = {
    containers.enable = true;
    # (AI) Podman 6.0+ format: unqualified search registries for short container image names
    containers.registries.settings = {
      unqualified-search-registries = [
        "docker.io"
        "quay.io"
      ];
    };
    oci-containers.backend = "podman";
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
    # (AI) Podman storage configuration for rootful containers
    containers.storage.rootful.settings = {
      storage = {
        driver = "overlay";
        runroot = "/run/containers/storage";
        graphroot = "/var/lib/containers/storage";
        options.overlay = {
          mount_program = "/run/current-system/sw/bin/fuse-overlayfs";
        };
      }; # storage
    };

    # VirtualBox
    virtualbox.host.enable = true;
  };

  # VPN
  services.mullvad-vpn.enable = true;
  services.mullvad-vpn.gui.enable = true;

  # Tor SOCKS proxy (127.0.0.1:9050)
  services.tor = {
    enable = true;
    client.enable = true;
  };

  environment.etc = {
    "ovmf/edk2-x86_64-secure-code.fd" = {
      source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-x86_64-secure-code.fd";
    };

    "ovmf/edk2-i386-vars.fd" = {
      source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-i386-vars.fd";
    };

    "distrobox/distrobox.conf".text = ''
      container_additional_volumes="/nix/store:/nix/store:ro /etc/profiles/per-user:/etc/profiles/per-user:ro /etc/static/profiles/per-user:/etc/static/profiles/per-user:ro"
    '';
  };

  # do not touch
  system.stateVersion = "25.11"; # Did you read the comment?

  # === SECRETS MANAGEMENT (sops-nix, system level) ===
  # Decrypts secrets at boot/switch time into /run/secrets/
  # See: https://michael.stapelberg.ch/posts/2025-08-24-secret-management-with-sops-nix/
  sops = {
    age.keyFile = "/home/veryloooong/.config/sops/age/keys.txt";
    defaultSopsFile = ./secrets/secrets.yaml;

    # Declare the secret so sops-nix knows which key to extract from the YAML file
    secrets."deepseek-api-key" = { };
    secrets."zai-api-key" = { };
    secrets."github-token" = { };
    secrets."telegram-bot-token" = { };
    secrets."telegram-allowed-users" = { };

    # Template: write the decrypted API key into the user's home directory
    templates."deepseek-api-key" = {
      content = "${config.sops.placeholder.deepseek-api-key}";
      path = "/home/veryloooong/.config/claude-code/api-key";
      owner = config.users.users.veryloooong.name;
    };

    # Z.ai (GLM) key, for Z.ai's Anthropic-compatible endpoint / GLM models.
    # Exported as $ZAI_API_KEY by modules/zsh.nix and passed to Hermes below.
    templates."zai-api-key" = {
      content = "${config.sops.placeholder.zai-api-key}";
      path = "/home/veryloooong/.config/claude-code/zai-api-key";
      owner = config.users.users.veryloooong.name;
    };

    # GitHub token: raises the skills-hub / API rate limit (5,000/hr instead of
    # 60/hr) and authenticates gh. Exported as $GITHUB_TOKEN by modules/zsh.nix.
    templates."github-token" = {
      content = "${config.sops.placeholder.github-token}";
      path = "/home/veryloooong/.config/claude-code/github-token";
      owner = config.users.users.veryloooong.name;
    };

    # Dotenv form of the same keys. services.hermes-agent concatenates its
    # environmentFiles into $HERMES_HOME/.env, and its gateway daemon runs
    # outside the interactive shell that exports DEEPSEEK_API_KEY.
    # Telegram credentials: single-host config, no conditional needed anymore.
    templates."hermes-env" = {
      content =
        "DEEPSEEK_API_KEY=${config.sops.placeholder.deepseek-api-key}\n"
        + "ZAI_API_KEY=${config.sops.placeholder.zai-api-key}\n"
        + "GITHUB_TOKEN=${config.sops.placeholder.github-token}\n"
        + ''
          TELEGRAM_BOT_TOKEN=${config.sops.placeholder.telegram-bot-token}
          TELEGRAM_ALLOWED_USERS=${config.sops.placeholder.telegram-allowed-users}
        '';
      path = "/home/veryloooong/.config/hermes/env";
      owner = config.users.users.veryloooong.name;
    };
  };
}
