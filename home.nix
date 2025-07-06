{ config, pkgs, ... }:

{
  programs.home-manager.enable = true;
  
  home.username = "veryloooong";
  home.homeDirectory = "/home/veryloooong";

  home.packages = with pkgs; [
    # development
    fzf
    zoxide
  ];

  # === DEVELOPMENT ===

  # Git and GitHub
  programs.git = {
    enable = true;
    userEmail = "hailong2004ptcnn@gmail.com";
    userName = "Hải Long";
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
  };

  # VSCode
  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhs;
  };

  # === GAMING ===
  programs.lutris = {
    enable = true;
    extraPackages = with pkgs; [
      gamescope
      gamemode
    ];
  };

  # === CUSTOMISATION ===

  # zsh config
  programs.zsh = {
    enable = true;
  };

  # oh-my-posh config
  programs.oh-my-posh = {
    enable = true;
  };

  # Configuration symlinks (very impure !!!)
  home.file = {
    # PowerShell config
    ".config/powershell/Microsoft.PowerShell_profile.ps1" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix/powershell/profile.ps1";
    };
    ".config/omp.toml" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix/powershell/omp.toml";
    };
  };

  home.stateVersion = "25.11";
}

