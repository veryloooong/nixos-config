{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak";
  };

  outputs = { self, nixpkgs, determinate, ... }:
  let 
    system = "x86_64-linux";
    common-modules = [
      ./configuration-common.nix
      nix-flatpak.nixosModules.nix-flatpak
      determinate.nixosModules.default
    ];
  in {
    nixosConfigurations.nixos-vm = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./configuration-vm.nix
      ] ++ common-modules;
    };

    nixosConfigurations.lebobo = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./configuration-laptop.nix
      ] ++ common-modules;
    };
  };
}
