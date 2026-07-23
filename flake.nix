{
  description = "NixOS configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    impermanence.url = "github:nix-community/impermanence";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hermes-agent.url = "github:NousResearch/hermes-agent/81eaedd0f5c471c7ee748990066135a684f3c962";
  };

  outputs = { self, nixpkgs, impermanence, home-manager, disko, hermes-agent, ... }@inputs:
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
      isam     = mkHost "isam";
      hermes   = mkHost "hermes";
    };
  };
}
