{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./global-default.nix
    ./disko.nix
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.home-manager
    ./modules/sops.nix
    ./modules/common.nix
    ./modules/system/gui/gui.nix
    ./modules/system/terminal/terminal.nix
    ./dynamic-grub.nix
    ./modules/network.nix
  ] ++ lib.optional (builtins.pathExists /etc/nixos/hardware-configuration.nix)
    /etc/nixos/hardware-configuration.nix;

}
