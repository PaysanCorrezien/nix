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
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # TODO:
    # stylix = {
    #   url = "github:danth/stylix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  # TODO : move computer conf on /machine/ subfolder
  # TEST: serv conf
  outputs = { disko, self, nixpkgs, home-manager, sops-nix, ... }@inputs:
    # TODO: make this a varaible too
    let system = "x86_64-linux";
    in {
      nixosConfigurations = {
        lenovo = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs nixpkgs; };
          modules = let
            pkgs = import nixpkgs {
              system = "x86_64-linux";
              config.allowUnfree = true;
            };
          in [
            ./global-default.nix
            ./disko.nix
            ./hosts/lenovo.nix
            disko.nixosModules.disko
            ({ config, pkgs, lib, ... }: {
              nixpkgs.hostPlatform = system;
              imports = lib.optional
                (builtins.pathExists /etc/nixos/hardware-configuration.nix)
                /etc/nixos/hardware-configuration.nix;
            })
          ];
        };
        # Add this new output for disko
        diskoConfigurations.default = {
          disko.devices = import ./disko.nix { inherit (nixpkgs) lib; };
        };

        # # NOTE: placeholder work wsl need to be done quick
        #         WSL = nixpkgs.lib.nixosSystem {
        #         specialArgs = { inherit inputs nixpkgs globalDefaults; };
        #         modules = let
        #           pkgs = import nixpkgs {
        #             system = globalDefaults.system;
        #           };
        #         in [
        #           ./hosts/WSL.nix
        #           ./modules/common.nix
        #           ./dynamic-grub.nix
        #           inputs.home-manager.nixosModules.home-manager
        #           {
        #             home-manager.users.dylan = import ./modules/home-manager/home.nix { inherit pkgs inputs; };
        #           }
        #         ];
        #       };
        #
        # # NOTE: placeholder for any no x86_64-linux based system 
        #       raspberryPi = nixpkgs.lib.nixosSystem {
        #         specialArgs = { inherit inputs nixpkgs globalDefaults; };
        #         modules = let
        #           pkgs = import nixpkgs {
        #             system = "aarch64-linux";
        #           };
        #         in [
        #           # Add Raspberry Pi specific modules here if needed
        #         ];
        #       };
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

