{ config, pkgs, ... }:

{
  programs.home-manager.enable = true;
  
  home.username = "veryloooong";
  home.homeDirectory = "/home/veryloooong";

  home.packages = with pkgs; [
    # development
    gh
    fzf
    zoxide
  ];

  # === DEVELOPMENT ===

  # Git
  programs.git = {
    enable = true;
    userEmail = "hailong2004ptcnn@gmail.com";
    userName = "Hải Long";
  };

  # VSCode
  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhs;
  };

  # === CUSTOMISATION ===

  # oh-my-posh config
  programs.oh-my-posh = {
    enable = true;
  };

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

