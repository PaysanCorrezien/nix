{ inputs, config, pkgs, ... }:

{
  # environment.systemPackages = with pkgs; [
  #   sops
  #   age
  # ];
  home.packages = with pkgs; [
  sops
  age 
  ];
    imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops = {
    defaultSopsFile = ./sops/kumo.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/dylan/.config/sops/age/keys.txt";
    secrets."nextcloudUrl"  = { 
      # owner = "dylan" ;
      };
    secrets."nextcloudUser"  = { 
      # owner = "dylan" ;
      };
      secrets."nextcloudKey" = {};
  };
}


# How it zork
# genere key :
# age-keygen -o ~/age-keys.txt
# copy the pub they in .sops.yaml on root of the nix repo :
# .sops.yaml : 
# age:
#  - recipient: thepubkeyhere
# create the secret file 'secrets.yaml' :
# nextcloudUrl: nextcloud_url
# nextcloudUser: nextcloud_user
#
