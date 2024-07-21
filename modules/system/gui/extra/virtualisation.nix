# NOTE : starting point
#TEST: need to be done

# virt.nix

{ config, pkgs, lib, ... }:
let cfg = config.settings;
in {
  config = lib.mkMerge [
    (lib.mkIf cfg.virtualisation.enable {
      programs.virt-manager.enable = true;
      virtualisation.libvirtd.enable = true;

      users.users.${cfg.username} = {
        isNormalUser = true;
        extraGroups = [ "libvirtd" "kvm" ];
      };

      # Uncomment the following if you need these settings
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

