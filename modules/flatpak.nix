# Flatpak management
{ ... }:

{
  services.flatpak.uninstallUnmanaged = true;

  services.flatpak.packages = [
    "com.usebottles.bottles"
    "app.twintaillauncher.ttl"
  ];
}
