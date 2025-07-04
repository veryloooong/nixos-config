# Flatpak management
{ lib, ... }:

{
  services.flatpak.uninstallUnmanaged = true;

  services.flatpak.packages = [
    "app.zen_browser.zen"
  ];
}
