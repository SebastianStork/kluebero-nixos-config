{
  description = "The NixOS configuration for the Kluebero GmbH";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {nixpkgs, ...} @ inputs: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    nixosConfigurations = {
      kluebero-vm1 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules = [./hosts/vm1];
      };
    };

    devShells.${system}.default = pkgs.mkShell {
      packages = [pkgs.sops];
    };
  };
}
