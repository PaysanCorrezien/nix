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
    disko = { url = "github:nix-community/disko"; };
    keybswitch = {
      # url = "git+file:///home/dylan/repo/keybswitch";
      url = "github:paysancorrezien/keybswitch";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    clovis = {
      # url = "git+file:///home/dylan/repo/clovis";
      url = "github:paysancorrezien/clovis";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };
  outputs =
    { self
    , nixpkgs
    , home-manager
    , sops-nix
    , disko
    , clovis
    , keybswitch
    , ...
    }@inputs:
    let
      mkSystem = hostname:
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs nixpkgs; };
          modules = [
            ./imports.nix
            (./hosts + "/${hostname}.nix")
            ({ config, ... }: {
              nixpkgs.hostPlatform = "${config.settings.architecture}-linux";
            })
          ];
        };
    in
    {
      nixosConfigurations = {
        lenovo = mkSystem "lenovo";
        workstation = mkSystem "workstation";
        homeserv = mkSystem "homeserv";
        ionos = mkSystem "ionos";
      };
    };
}
