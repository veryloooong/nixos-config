# Flatpak management
{ ... }:

{
  services.flatpak.remotes = [
    {
      name = "flathub";
      location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
    }
    {
      name = "flathub-beta";
      location = "https://flathub.org/beta-repo/flathub-beta.flatpakrepo";
    }
  ];

  services.flatpak.uninstallUnmanaged = true;

  services.flatpak.packages = [
    "com.usebottles.bottles"
    "app.twintaillauncher.ttl"
    "org.vinegarhq.Sober"
    "com.bishwasaha.Koncentro"
    { appId = "com.stremio.Stremio"; origin = "flathub-beta"; }
  ];
}
