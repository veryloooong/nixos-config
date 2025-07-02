{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
  };

  outputs = { self, nixpkgs, determinate, ... }: {
    nixosConfigurations.nixos-vm = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration-vm.nix
        determinate.nixosModules.default
      ];
    };

    nixosConfigurations.lebobo = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration-laptop.nix
        determinate.nixosModules.default
      ];
    };
  };
}
