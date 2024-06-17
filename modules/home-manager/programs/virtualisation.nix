#NOTE : starting point
#TEST: need to be done
{ config, pkgs, ... }:

let
  username = "dylan"; 
in
{
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      user = username;
    };
  };

  services.libvirtd.enable = true;

  programs.virtmanager.enable = true;

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "libvirtd" "kvm" ];
  };

  home-manager.users.${username} = {
    programs.dconf = {
      enable = true;
      settings = {
        "org/virt-manager/virt-manager/connections" = {
          autoconnect = ["qemu:///system"];
          uris = ["qemu:///system"];
        };
      };
    };
  };
}

