# sops.nix
{ config, pkgs, ... }:

let
  secrets = import <sops-nix> {
    inherit pkgs;
    sopsFiles = {
      nextcloud = ./secrets/secrets.yaml;
    };
  };
  username = config.users.users.user.name;
  ageKeyFilePath = "/home/${username}/.config/sops/age/keys.txt";
in
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = ageKeyFilePath;

  environment.systemPackages = with pkgs; [
    nextcloud-client
    nextcloudcmd
    yq
  ];

  systemd.services.nextcloud-setup = {
    description = "Setup Nextcloud with credentials";
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = ''
        if [ -f ${ageKeyFilePath} ]; then
          export SOPS_AGE_KEY_FILE=${ageKeyFilePath}
          nextcloud_user=$(sops -d ${secrets.nextcloud.path} | yq e '.nextcloud.username' -)
          nextcloud_pass=$(sops -d ${secrets.nextcloud.path} | yq e '.nextcloud.password' -)
          nextcloud_url=$(sops -d ${secrets.nextcloud.path} | yq e '.nextcloud.url' -)
          nextcloudcmd --user $nextcloud_user --password $nextcloud_pass $nextcloud_url ~/Nextcloud
        else
          echo "AGE key file not found. Skipping Nextcloud setup."
        fi
      '';
      Type = "oneshot";
      RemainAfterExit = true;
    };
    wantedBy = [ "multi-user.target" ];
  };
}

