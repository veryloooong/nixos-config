# TODO: repopulate this file when installed on laptop

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration-laptop.nix
    ];

  # Bootloader // TODO be repopulated later
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "lebobo"; # Define your hostname.

  services.libinput.enable = true;

  environment.systemPackages = with pkgs; [
    # Gaming
    protonup-qt
    (heroic.override {
      extraPkgs = pkgs: [
        pkgs.gamescope
	pkgs.gamemode
      ];
    })
  ];

  # Gaming
  programs.gamescope.enable = true;
  programs.gamemode.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
  };

  system.stateVersion = "25.11"; # Did you read the comment?
}
