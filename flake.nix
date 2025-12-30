{
  description = "NixOS system flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    burpsuitepro = {
      url = "gitlab:_VX3r/burpsuite-pro-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-gaming.url = "github:fufexan/nix-gaming";
    vicinae.url = "github:vicinaehq/vicinae";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      determinate,
      nix-flatpak,
      home-manager,
      lanzaboote,
      vicinae,
      ...
    }:
    let
      system = "x86_64-linux";
      common-modules = [
        ./configuration-common.nix

        # Determinate has garbage collection + Flakehub search
        determinate.nixosModules.default

        # flatpaks
        nix-flatpak.nixosModules.nix-flatpak
        ./modules/flatpak.nix

        # home manager
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.veryloooong = import ./home.nix;
          home-manager.extraSpecialArgs = {
            inherit inputs;
          };
        }
      ];
    in
    {
      nixosConfigurations.nixos-vm = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./configuration-vm.nix
        ]
        ++ common-modules;
      };

      nixosConfigurations.lebobo = nixpkgs.lib.nixosSystem rec {
        inherit system;
        modules = [
          ./configuration-laptop.nix
          lanzaboote.nixosModules.lanzaboote

        ]
        ++ common-modules;
      };
    };
}
