{ config, pkgs, ... }:

{
  imports = [
    ./modules/zsh.nix
  ];

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

  # do not touch
  home.stateVersion = "25.11";
}

