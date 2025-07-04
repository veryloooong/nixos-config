{ config, pkgs, ... }:

{
  programs.home-manager.enable = true;
  
  home.username = "veryloooong";
  home.homeDirectory = "/home/veryloooong";

  home.packages = with pkgs; [
    gh
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

  # Shell aliases
  home.shellAliases = {
    ls = "ls -l"
  };

  # Shell config
  home.file = {
    ".config/powershell/Microsoft.PowerShell_profile.ps1" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix/powershell/profile.ps1"
    };
  };

  home.stateVersion = "25.11";
}

