# home-virtualization.nix
{ config, settings, pkgs, lib, ... }:
let cfg = settings.virtualisation.enable;

in {
  # Enable virt-manager

  config = lib.mkIf cfg {
    dconf.settings = {
      "org/virt-manager/virt-manager" = { system-tray = true; };
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = [ "qemu:///system" ];
        uris = [ "qemu:///system" ];
      };
    };
  };
}
