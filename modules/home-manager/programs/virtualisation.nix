# home-virtualization.nix
{ config, pkgs, lib, ... }:

{
  # Enable virt-manager
  dconf.settings = {
    "org/virt-manager/virt-manager" = { system-tray = true; };
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };
}
