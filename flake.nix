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
    };
    # keybswitch = {
    #   # url = "git+file:///home/dylan/repo/keybswitch";
    #   url = "github:paysancorrezien/keybswitch";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # clovis = {
    #   # url = "git+file:///home/dylan/repo/clovis";
    #   url = "github:paysancorrezien/clovis";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # plasma-manager = {
    #   url = "github:nix-community/plasma-manager";
    #   inputs.nixpkgs.follows = "nixpkgs";
    #   inputs.home-manager.follows = "home-manager";
    # };
    nixos-wsl = {
      url = "github:nix-community/nixos-wsl";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ags = {
      url = "github:aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tailscale-ssh = {
      # url = "git+file:///home/dylan/repo/tailscale-ssh.nix";
      url = "github:paysancorrezien/tailscale-ssh.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    yazi-plugins = {
      # url = "github:lordkekz/nix-yazi-plugins?ref=main";
      # url = "git+file:///home/dylan/repo/nix-yazi-plugins";
      url = "github:paysancorrezien/nix-yazi-plugins?ref=main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };
  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      sops-nix,
      disko,
      # clovis,
      # keybswitch,
      nixos-wsl,
      ...
    }@inputs:
    let
      mkSystem =
        hostname:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs nixpkgs;
          };
          modules = [
            ./imports.nix
            (./hosts + "/${hostname}.nix")
            (
              { config, ... }:
              {
                nixpkgs.hostPlatform = "${config.settings.architecture}-linux";
              }
            )
          ];
        };
    in
    {
      nixosConfigurations = {
        lenovo = mkSystem "lenovo";
        workstation = mkSystem "workstation";
        chi = mkSystem "chi";
        homeserv = mkSystem "homeserv";
        ionos = mkSystem "ionos";
        wsl = mkSystem "wsl";
      };
    };
}
