{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    sops-nix.url = "github:Mic92/sops-nix";
  };

# TODO : move computer conf on /machine/ subfolder
# TEST: serv conf
  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        ./dynamic-grub.nix  # Include the dynamic GRUB module
        inputs.home-manager.nixosModules.home-manager
      ];
    };
    # nixosConfigurations.homeserver = nixpkgs.lib.nixosSystem {
    #   specialArgs = { inherit inputs; };
    #   modules = [
    #     ./homeserver.nix
    #     ./dynamic-grub.nix  # Include the dynamic GRUB module
    #     inputs.home-manager.nixosModules.home-manager
    #   ];
    # };
  };
}

