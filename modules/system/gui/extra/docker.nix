{ config, pkgs, lib, ... }:

let
  userName = "dylan"; #TODO: rename this to docker / nvidia ?
  cfg = config.settings.docker.enable;
in
{
  config = lib.mkIf (cfg) {
    virtualisation.docker = {
      enable = true;
      enableOnBoot = true;
      logDriver = "json-file";
      extraOptions = ''
        --log-opt max-size=10m --log-opt max-file=3
      '';
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };

    users.users.${userName} = {
      extraGroups = [ "docker" ];
    };

    environment.systemPackages = with pkgs; [
      docker
      docker-compose
      lazydocker
    ];

    environment.shellAliases = {
      dku = "docker-compose up -d";
      dkd = "docker-compose down";
    };
  };
}
