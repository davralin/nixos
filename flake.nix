{
  description = "NixOS configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    impermanence.url = "github:nix-community/impermanence";
  };

  outputs = { self, nixpkgs, impermanence, ... }@inputs:
  let
    mkHost = hostName: nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [ ./hosts/${hostName} ];
    };
  in
  {
    nixosConfigurations = {
      mierin   = mkHost "mierin";
      home-nas = mkHost "home-nas";
      away-nas = mkHost "away-nas";
    };
  };
}
