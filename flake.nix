{
  description = "NixOS configuration";

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
    # TODO: add yazi flake 
    sops-nix.url = "github:Mic92/sops-nix";
  };

# TODO : move computer conf on /machine/ subfolder
# TEST: serv conf
  outputs = { self, nixpkgs, home-manager,sops-nix, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

    in {
        nixosConfigurations = {
        lenovo = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs pkgs ; };
          modules = [
            # inputs.sops-nix.nixosModules.sops
            # inputs.home-manager.nixosModules.home-manager
            ./hosts/lenovo.nix
            ./modules/common.nix
	          ./dynamic-grub.nix
	          ./configuration.nix
            # ./modules/sops.nix
            # ./testcreds.nix
            # ./modules/home-manager/programs/nextloud-cli.nix
            {
              home-manager.users.dylan = import ./modules/home-manager/home.nix { inherit pkgs inputs; };
            }
          ];
        };

        WSL = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/WSL.nix
            ./modules/common.nix
            ./dynamic-grub.nix
            inputs.home-manager.nixosModules.home-manager
            {
             home-manager.users.dylan = import ./modules/home-manager/home.nix;
            }
          ];
        };
      };
    };
    # nixosConfigurations.homeserver = nixpkgs.lib.nixosSystem {
    #   specialArgs = { inherit inputs; };
    #   modules = [
    #     ./homeserver.nix
    #     ./dynamic-grub.nix  # Include the dynamic GRUB module
    #     inputs.home-manager.nixosModules.home-manager
    #   ];
    # };
}


