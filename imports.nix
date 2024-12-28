{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports =
    [
      ./global-default.nix
      ./disko.nix
      inputs.disko.nixosModules.disko
      inputs.home-manager.nixosModules.home-manager
      inputs.stylix.nixosModules.stylix
      inputs.tailscale-ssh.nixosModules.default
      ./modules/sops.nix
      ./modules/network/ssh.nix
      ./modules/common.nix
      ./modules/system/gui/gui.nix
      ./modules/system/terminal/terminal.nix
      ./modules/monitoring/default.nix
      ./cachix.nix
      ./dynamic-grub.nix
      ./modules/network/default.nix
    ]
    ++ lib.optional (builtins.pathExists /etc/nixos/hardware-configuration.nix) /etc/nixos/hardware-configuration.nix;

  nixpkgs.overlays = [
    # inputs.hyprpanel.overlay

    inputs.yazi-plugins.overlays.default
    inputs.busygit.overlays.default

    #NOTE: build xdf-portal-termfilechooser
    (final: prev: {
      xdg-desktop-portal-termfilechooser =
        final.callPackage ./modules/home-manager/terminals/core/yazi/xdg-desktop-portal-termfilechooser.nix
          { };
    })
  ];
}
