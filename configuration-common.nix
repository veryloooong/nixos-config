{ config, pkgs, ... }:

let
  microsoft-aptos = pkgs.callPackage ./custom/aptos.nix { inherit pkgs; };
in
{
  # TODO: remove when it is resolved?
  nixpkgs.config.permittedInsecurePackages = [
    "qtwebengine-5.15.19"
  ];

  # Enable flakes and the new Nix CLI
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.trusted-users = [
    "root"
    "veryloooong"
  ];

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
    ]; # sudo access
    shell = pkgs.zsh;
    useDefaultShell = true;
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

    # development
    git
    sccache
    gnumake

    # productivity
    chromium
  ];

  # fonts
  # fonts.fontDir.enable = true;
  fonts.enableDefaultPackages = true;
  fonts.packages = with pkgs; [
    cascadia-code
    inter
    noto-fonts
    noto-fonts-emoji
    noto-fonts-cjk-sans
    corefonts
    microsoft-aptos
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
      aggregated = pkgs.buildEnv {
        name = "system-fonts-and-icons";
        paths =
          config.fonts.packages
          ++ (with pkgs; [
            bibata-cursors
          ]);
        pathsToLink = [
          "/share/fonts"
          "/share/icons"
        ];
      };
    in
    {
      "/usr/share/fonts" = mkRoSymBind "${aggregated}/share/fonts";
      "/usr/share/icons" = mkRoSymBind "${aggregated}/share/icons";
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
    libraries = with pkgs; [
      libxml2
    ];
  };

  # Enable flatpaks
  services.flatpak.enable = true;

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
  ];

  # do not touch
  system.stateVersion = "25.11"; # Did you read the comment?
}
