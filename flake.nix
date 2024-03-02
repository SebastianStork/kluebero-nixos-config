{
  description = "The NixOS configuration for the Kluebero GmbH";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    disko,
    ...
  }: {
    nixosConfigurations = {
      kluebero-vm1 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          ./configuration.nix

          disko.nixosModules.default
        ];
      };
    };
  };
}
