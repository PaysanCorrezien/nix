# NOTE : starting point
#TEST: need to be done

{ config, pkgs, lib, ... }:
let
  username = "dylan";
  cfg = config.settings.virtualisation.enable;
in {

  config = lib.mkMerge [
    (lib.mkIf cfg {
      programs.virt-manager.enable = true;

      virtualisation.libvirtd.enable = true;

      users.users.${username} = {
        isNormalUser = true;
        extraGroups = [ "libvirtd" "kvm" ];
      };

      # programs.dconf = {
      #   enable = true;
      #   settings = {
      #     "org/virt-manager/virt-manager/connections" = {
      #       autoconnect = [ "qemu:///system" ];
      #       uris = [ "qemu:///system" ];
      #     };
      #   };
      # };
    })
  ];
}

