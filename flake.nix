{
  description = "NixOS configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
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
    nixos-wsl = {
      url = "github:nix-community/nixos-wsl";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # ags = {
    #   url = "github:aylur/ags";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # wezterm = {
    #   url = "github:wez/wezterm/main?dir=nix";
    #   #NOTE: https://github.com/wez/wezterm/pull/5576
    #   # url = "github:e82eric/wezterm/float-pane?dir=nix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    tailscale-ssh = {
      # url = "git+file:///home/dylan/repo/tailscale-ssh.nix";
      url = "github:paysancorrezien/tailscale-ssh.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    yazi-plugins = {
      # url = "github:lordkekz/nix-yazi-plugins?ref=main";
      # url = "git+file:///home/dylan/repo/nix-yazi-plugins?ref=0.4";
      # url = "github:paysancorrezien/nix-yazi-plugins";
      url = "github:paysancorrezien/nix-yazi-plugins?ref=main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # busygit = {
    #   url = "github:paysancorrezien/busygit";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    hyprpanel = {
      url = "github:Jas-SinghFSU/HyprPanel";
      # url = "git+file:///home/dylan/repo/HyprPanel";
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
      # mkSystem takes hostname and import type (desktop, server, wsl)
      mkSystem = hostname: importType:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs nixpkgs;
          };
          modules = [
            (./modules/imports + "/${importType}.nix")
            (./hosts + "/${hostname}.nix")
            ({ config, ... }: {
              nixpkgs.hostPlatform = "${config.settings.architecture}-linux";
            })
          ];
        };
    in
    {
      nixosConfigurations = {
        # Desktops/laptops
        lenovo = mkSystem "lenovo" "desktop";
        workstation = mkSystem "workstation" "desktop";
        # Servers
        chi = mkSystem "chi" "server";
        homeserv = mkSystem "homeserv" "server";
        ionos = mkSystem "ionos" "server";
        vmware = mkSystem "vmware" "server";
        # WSL
        wsl = mkSystem "wsl" "wsl";
      };
    };
}
