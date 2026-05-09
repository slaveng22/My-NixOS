{
  description = "redpanda NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }: {
    nixosConfigurations.redpanda = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        unstable = nixpkgs-unstable.legacyPackages.x86_64-linux;
      };
      modules = [
        ./hosts/redpanda/default.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {
            unstable = nixpkgs-unstable.legacyPackages.x86_64-linux;
          };
          home-manager.users.slaven = import ./modules/home/default.nix;
        }
      ];
    };
  };
}
