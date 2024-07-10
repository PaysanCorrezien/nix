#NOTE : starting point
#TEST: need to be done
{ config, pkgs, ... }:

let
  username = "dylan"; 
in
{
  programs.virt-manager.enable = true;

  virtualisation.libvirtd = {
    enable = true;
  };


  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "libvirtd" "kvm" ];
  };

  # programs.dconf = {
  #   enable = true;
  #   settings = {
  #     "org/virt-manager/virt-manager/connections" = {
  #       autoconnect = ["qemu:///system"];
  #       uris = ["qemu:///system"];
  #     };
  #   };
  # };
}

