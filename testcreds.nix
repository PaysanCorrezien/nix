# NOTE: test done to read from my sops file that contain and url and an username 
# WORK
{ config, pkgs, ... }:

{
  systemd.services.test-sops-secrets = {
    description = "Test SOPS Secrets";
    serviceConfig = {
      ExecStart = "${pkgs.bash}/bin/bash -c 'echo Nextcloud URL: $(cat ${config.sops.secrets.nextcloudUrl.path}) && echo Nextcloud User: $(cat ${config.sops.secrets.nextcloudUser.path})'";
    };
    wantedBy = [ "multi-user.target" ];
  };
}

