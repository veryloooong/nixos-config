{
  config,
  pkgs,
  lib,
  system ? pkgs.system,
  ...
}:

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

  # Firmware/hardware stuff
  hardware.cpu.amd.updateMicrocode = true;
  services.fwupd.enable = true;

  # SysRq
  boot.kernel.sysctl."kernel.sysrq" = 502;

  # swap fix
  boot.resumeDevice = "/dev/disk/by-label/swap"; # Replace with your actual swap UUID

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  networking.hostName = "lebobo"; # Define your hostname.

  services.libinput.enable = true;

  environment.systemPackages = with pkgs; [
    # lmao
    stm32cubemx

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

    # KDE
    kdePackages.plasma-vault # Encrypted folders
    kdePackages.kup # Backup
    kdePackages.kcalc # Calculator

    # Financial management
    mmex

    # Virtualisation
    distrobox
    podman-compose
    crun
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
  virtualisation.containers.enable = true;
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };
  virtualisation.vmware.host.enable = true;
  users.users.veryloooong.extraGroups = [ "podman" "kvm" ];

  environment.etc = {
    "ovmf/edk2-x86_64-secure-code.fd" = {
      source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-x86_64-secure-code.fd";
    };

    "ovmf/edk2-i386-vars.fd" = {
      source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-i386-vars.fd";
    };

    "distrobox/distrobox.conf".text = ''
  container_additional_volumes="/nix/store:/nix/store:ro /etc/profiles/per-user:/etc/profiles/per-user:ro /etc/static/profiles/per-user:/etc/static/profiles/per-user:ro"
'';
  };

  system.stateVersion = "25.11"; # Did you read the comment?
}
