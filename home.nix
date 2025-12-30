{
  inputs,
  config,
  pkgs,
  # pkgs-softmaker,
  ...
}:

{
  imports = [
    ./modules/zsh.nix
    inputs.zen-browser.homeModules.twilight
    inputs.vicinae.homeManagerModules.default
  ];

  programs.home-manager.enable = true;
  programs.zen-browser.enable = true;
  programs.zen-browser.nativeMessagingHosts = [ pkgs.firefoxpwa ];

  fonts.fontconfig.enable = true;

  home.username = "veryloooong";
  home.homeDirectory = "/home/veryloooong";
  home.sessionPath = [
    "$HOME/.local/bin"
  ];
  home.packages = with pkgs; [
    # shell
    hexyl
    android-tools # adb and others
    yt-dlp
    ffmpeg
    hyperfine
    dust
    p7zip
    devenv
    unrar
    python312

    # productivity
    libreoffice
    thunderbird
    onedrive
    onedrivegui
    anki
    vscode-runner
    kdePackages.kolourpaint
    xournalpp
    teams-for-linux
    kdePackages.kdenlive
    pdfstudioviewer
    lmstudio
    zettlr

    # remote
    kdePackages.krdc

    # security work
    inputs.burpsuitepro.packages.${system}.burpsuitepro
    wireshark

    # language servers
    nixd
    clang-tools
    pyright
    arduino-cli
    arduino-language-server

    # formatters
    nixfmt-rfc-style
    ruff

    # runtimes
    uv
    lua
    luarocks
    openjdk
    nodenv

    # Research software
    zotero

    # debugging
    lldb # for rust
    gdb # for c++

    # entertainment
    qbittorrent
    vesktop
    vlc

    # wine
    inputs.nix-gaming.packages.${pkgs.system}.wine-ge
  ];

  # === DEVELOPMENT ===

  # Git and GitHub
  programs.git = {
    enable = true;
    settings = {
      user = {
        email = "hailong2004ptcnn@gmail.com";
        name = "Hải Long";
      };
      alias = {
        co = "checkout";
        cam = "commit -am";
        pl = "pull";
        f = "fetch";
        ph = "push";
        aa = "add .";
        a = "add";
      };
      init.defaultBranch = "main";
    };
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
  };

  programs.delta = {
    enable = true;
    options = {
      side-by-side = true;
      line-numbers = true;
      dark = true;
      syntax-theme = "OneHalfDark";
    };
    enableGitIntegration = true;
  };

  # VSCode
  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhs;
  };

  programs.zed-editor = {
    enable = true;
    package = pkgs.zed-editor.fhsWithPackages(
      o: with o; [
        openssl
        zlib
      ]
    );
  };

  # direnv
  programs.direnv = {
    enable = true;
    enableZshIntegration = true; # see note on other shells below
    nix-direnv.enable = true;
  };

  # other dotfiles
  home.file = {
    ".config/rustfmt/rustfmt.toml".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix/config/rustfmt/rustfmt.toml";
    ".config/zellij/config.kdl".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix/config/zellij/config.kdl";
    ".config/compose/windows.yaml".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix/config/compose/windows.yaml";
    ".config/compose/macos.yaml".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix/config/compose/macos.yaml";
  };

  # === GAMING ===
  programs.lutris = {
    enable = true;
    extraPackages = with pkgs; [
      gamescope
      gamemode
      mangohud
    ];
  };

  # obs
  programs.obs-studio = {
    enable = true;
    plugins = [
      pkgs.obs-studio-plugins.obs-vkcapture
    ];
  };

  # === CUSTOMISATION ===

  # eza = ls replacement
  programs.eza = {
    enable = true;
    colors = "always";
    icons = "auto";
    git = true;
    enableZshIntegration = true;
  };

  # bat = cat replacement
  programs.bat = {
    enable = true;
    config = {
      style = "numbers,changes,header";
    };
  };

  # zoxide = cd replacement
  programs.zoxide = {
    enable = true;
    options = [
      "--cmd"
      "cd"
    ];
  };

  # fzf = fuzzy finder
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  # zellij = tmux but noob
  programs.zellij = {
    enable = true;
  };

  # vicinae
  services.vicinae = {
    enable = true; # default: false
    autoStart = true; # default: true
  };

  # do not touch
  home.stateVersion = "25.11";
}
