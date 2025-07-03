# TODO: repopulate this file when installed on laptop

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration-laptop.nix
    ];

  # Bootloader // TODO be repopulated later
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "lebobo"; # Define your hostname.

  services.libinput.enable = true;

  environment.systemPackages = with pkgs; [
  ];

  services.flatpak.packages = [
    "com.valvesoftware.Steam"
    "net.davidotek.pupgui2"
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
