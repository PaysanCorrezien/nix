{ inputs, config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    sops
    age
  ];
  # home.packages = with pkgs; [
  # sops
  # age 
  # ];
    imports = [
    # inputs.sops-nix.homeManagerModules.sops
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    defaultSopsFile = ./sops/kumo.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/dylan/.config/sops/age/keys.txt";
    secrets = {
      "nextcloudUrl" = { owner = "dylan"; };
      "nextcloudUser" = { owner = "dylan"; };
      "nextcloudKey" = {};
      # New Thunderbird secrets
      "thunderbird/account1/name" = { owner = "dylan"; };
      "thunderbird/account1/email" = { owner = "dylan"; };
      "thunderbird/account1/server" = { owner = "dylan"; };
      "thunderbird/account1/port" = { owner = "dylan"; };
      "thunderbird/account1/username" = { owner = "dylan"; };
      # # "thunderbird.account1.password" = { owner = "dylan"; };
      "thunderbird/account2/name" = { owner = "dylan"; };
      "thunderbird/account2/email" = { owner = "dylan"; };
      "thunderbird/account2/server" = { owner = "dylan"; };
      "thunderbird/account2/port" = { owner = "dylan"; };
      "thunderbird/account2/username" = { owner = "dylan"; };
      # "thunderbird.account2.password" = { owner = "dylan"; };
      # Add more accounts as needed
    };
  };

  #     systemd.services.sometestservice = {
  #   script = ''
  #     mkdir -p /home/dylan/sometestservice
  #     echo "
  #     Hey bro! I'm a service, and imma send this secure password:
  #     $(cat ${config.sops.secrets."nextcloudUrl".path})
  #     located in:
  #     ${config.sops.secrets."nextcloudUrl".path}
  #     to database and hack the mainframe
  #     " > /home/dylan/sometestservice/testfile
  #   '';
  #   serviceConfig = {
  #     User = "dylan";
  #     WorkingDirectory = "/home/dylan/";
  #   };
  #   wantedBy = [ "multi-user.target" ];
  # };
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
