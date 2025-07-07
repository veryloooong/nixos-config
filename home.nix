{ config, pkgs, ... }:

{
  imports = [
    ./modules/zsh.nix
  ];

  programs.home-manager.enable = true;
  
  home.username = "veryloooong";
  home.homeDirectory = "/home/veryloooong";

  home.packages = with pkgs; [
    # shell
    hexyl

    # productivity
    thunderbird
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
    options = [ "--cmd" "cd" ];
  };

  # fzf = fuzzy finder
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  # zellij = tmux but noob
  programs.zellij = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      theme = "one-half-dark";
      default-mode = "locked";
    };
  };

  # do not touch
  home.stateVersion = "25.11";
}

