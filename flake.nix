{
  description = "NixOS system flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-softmaker.url = "github:nixos/nixpkgs/566e53c2ad750c84f6d31f9ccb9d00f823165550";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    burpsuitepro = {
      type = "github";
      owner = "xiv3r";
      repo = "Burpsuite-Professional";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      determinate,
      nix-flatpak,
      home-manager,
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
	    pkgs-softmaker = import inputs.nixpkgs-softmaker {
	      inherit system;
	      config.allowUnfree = true;
	    };
	  };
        }
      ];
    in
    {
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
