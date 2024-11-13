# docker.nix
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.settings.docker.enable;
  username = config.settings.username;
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

    # Basic directory setup - just create the base docker directory
    systemd.tmpfiles.rules = [
      "d /home/${username}/docker 0755 ${username} users -"
    ];

    # Simple ACL setup - this gives your user full control of the docker directory
    system.activationScripts.dockerDirPermissions = {
      text = ''
        # Create base docker directory if it doesn't exist
        mkdir -p /home/${username}/docker

        # Set ownership and permissions
        chown -R ${username}:users /home/${username}/docker
        chmod -R u=rwX,g=rX,o= /home/${username}/docker

        # Set ACLs for inheritance
        ${pkgs.acl}/bin/setfacl -R -d -m u::rwX,g::rX,o::- /home/${username}/docker
      '';
      deps = [ ];
    };

    users.users.${username} = {
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
