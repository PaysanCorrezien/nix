{ config, pkgs, lib, ... }:

let
  userName = "dylan";
#TODO: rename this to docker / nvidia ?
 cfg = config.settings.ai.server.enable;
in {
  config = lib.mkIf (cfg) {
    virtualisation.docker = {
      enable = true;
      enableOnBoot = true;
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
    };
}

