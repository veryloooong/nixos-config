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

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

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

  system.stateVersion = "25.11"; # Did you read the comment?
}
