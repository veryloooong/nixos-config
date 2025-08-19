{ config, pkgs, lib, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration-laptop.nix
  ];

  # Bootloader and boot screen
  # boot.loader.systemd-boot.enable = true;

  boot.loader.systemd-boot.enable = lib.mkForce false;

    boot.lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };

  boot.loader.efi.canTouchEfiVariables = true;
  boot.plymouth.enable = true;

  # swap fix
  boot.resumeDevice = "/dev/disk/by-label/swap"; # Replace with your actual swap UUID

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  networking.hostName = "lebobo"; # Define your hostname.

  services.libinput.enable = true;

  environment.systemPackages = with pkgs; [
    # secure boot
    sbctl

    # Gaming
    protonup-qt
    (heroic.override {
      extraPkgs = pkgs: [
        pkgs.gamescope
        pkgs.gamemode
      ];
    })

    # utility
    cheese # camera app

    # virtualisation
    swtpm

    # KDE
    kdePackages.plasma-vault # Encrypted folders
    kdePackages.kup # Backup
    kdePackages.kcalc # Calculator
    #kdePackages.kamoso # Laptop camera // why is it broken??? qt5 type shi
  ];

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
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      ovmf.enable = true;
      ovmf.packages = [ pkgs.OVMFFull.fd ];
      swtpm.enable = true;
      vhostUserPackages = [ pkgs.virtiofsd ];
    };
  };
  programs.virt-manager.enable = true;
  environment.etc = {
    "ovmf/edk2-x86_64-secure-code.fd" = {
      source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-x86_64-secure-code.fd";
    };

    "ovmf/edk2-i386-vars.fd" = {
      source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-i386-vars.fd";
    };
  };

  system.stateVersion = "25.11"; # Did you read the comment?
}
