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
      url = "git+file:///home/dylan/repo/keybswitch";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    clovis = {
      url = "git+file:///home/dylan/repo/clovis";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, home-manager, sops-nix, disko, clovis, keybswitch
    , ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      nixosConfigurations = {
        lenovo = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs nixpkgs; };
          modules = [ ./imports.nix ./hosts/lenovo.nix ];
        };
        workstation = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs nixpkgs; };
          modules = [ ./imports.nix ./hosts/workstation.nix ];
        };
      };
    };
}
