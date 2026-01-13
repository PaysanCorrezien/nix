# Base imports for ALL hosts (desktop, server, wsl)
{ inputs, lib, ... }:

{
  imports = [
    ../../global-default.nix
    ../../disko.nix
    ../../cachix.nix
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.home-manager
    inputs.sops-nix.nixosModules.sops
    inputs.tailscale-ssh.nixosModules.default
    ../sops.nix
    ../common.nix
    ../network/default.nix
    ../network/ssh.nix
  ] ++ lib.optional (builtins.pathExists /etc/nixos/hardware-configuration.nix) /etc/nixos/hardware-configuration.nix;

  # Allow unfree and broken packages (needed for some development tools)
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowBroken = true;

  # Overlays available to all hosts
  nixpkgs.overlays = [
    inputs.yazi-plugins.overlays.default
    # inputs.busygit.overlays.default
    (final: prev: {
      xdg-desktop-portal-termfilechooser =
        final.callPackage ../home-manager/terminals/core/yazi/xdg-desktop-portal-termfilechooser.nix { };
    })
  ];
}
