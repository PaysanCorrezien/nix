{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./global-default.nix
    ./disko.nix
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.home-manager
    inputs.stylix.nixosModules.stylix
    ./modules/sops.nix
    ./modules/network/ssh.nix
    ./modules/common.nix
    ./modules/system/gui/gui.nix
    ./modules/system/terminal/terminal.nix
    ./modules/monitoring/default.nix
    ./dynamic-grub.nix
    ./modules/network/default.nix
  ] ++ lib.optional (builtins.pathExists /etc/nixos/hardware-configuration.nix)
    /etc/nixos/hardware-configuration.nix;

}
