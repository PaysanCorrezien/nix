#TODO: crake a mkdsopssecrets fn that handle all the boiletplate
{
  lib,
  inputs,
  config,
  pkgs,
  ...
}:

let
  cfg = config.settings.sops;
in
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  options.settings = lib.mkOption {
    type = lib.types.submodule {
      options.sops = lib.mkOption {
        type = lib.types.submodule {
          options = {
            enable = lib.mkEnableOption "Enable sops configuration";
            enableGlobal = lib.mkEnableOption "Enable global secrets";
            machineType = lib.mkOption {
              type = lib.types.enum [
                "desktop"
                "homeserver"
                "vps"
              ];
              description = "Type of the machine (desktop, homeserver, or vps)";
            };
          };
        };
        default = { };
        description = "Sops-related settings";
      };
    };
    default = { };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        environment.systemPackages = with pkgs; [
          sops
          age
        ];
        environment.variables.SOPS_AGE_KEY_FILE = "/var/lib/secrets/${config.networking.hostName}.txt";
        sops = {
          defaultSopsFormat = "yaml";
          age.keyFile = "/var/lib/secrets/${config.networking.hostName}.txt";
        };
      }

      (lib.mkIf cfg.enableGlobal {
        sops.secrets = {
          "tailscale_auth_key" = {
            sopsFile = ./sops/kumo.yaml;
            group = "root";
            mode = "0440";
          };
          "nextcloudUrl" = {
            sopsFile = ./sops/kumo.yaml;
            owner = "dylan";
          };
          "atuin_sync_address" = {
            sopsFile = ./sops/kumo.yaml;
            owner = "dylan";
          };
        };
      })

      (lib.mkIf (cfg.machineType == "desktop") {
        sops.secrets = {
          "nextcloudUser" = {
            sopsFile = ./sops/pasokon.yaml;
            owner = "dylan";
          };
          "wifi_homekey" = {
            sopsFile = ./sops/pasokon.yaml;
            owner = "dylan";
          };
          # Thunderbird secrets
          "thunderbird/account1/name" = {
            sopsFile = ./sops/pasokon.yaml;
            owner = "dylan";
          };
          "thunderbird/account1/email" = {
            sopsFile = ./sops/pasokon.yaml;
            owner = "dylan";
          };
          "thunderbird/account2/name" = {
            sopsFile = ./sops/pasokon.yaml;
            owner = "dylan";
          };
          "thunderbird/account2/email" = {
            sopsFile = ./sops/pasokon.yaml;
            owner = "dylan";
          };
        };
      })
      #TODO: maybe only root shoudl have access to these secrets or some of them
      (lib.mkIf (cfg.machineType == "homeserver") {
        sops.secrets = {
          "nextcloudUsername" = {
            sopsFile = ./sops/ie.yaml;
            owner = "dylan";
          };
          "sync_password" = {
            sopsFile = ./sops/ie.yaml;
            owner = "dylan";
          };
          "discordWebhookUrl" = {
            sopsFile = ./sops/ie.yaml;
            owner = "dylan";
          };
          "sync_localDir" = {
            sopsFile = ./sops/ie.yaml;
            owner = "dylan";
          };
          "sync_remoteDir" = {
            sopsFile = ./sops/ie.yaml;
            owner = "dylan";
          };
          "discordWebhookUrlBackup" = {
            sopsFile = ./sops/ie.yaml;
            owner = "dylan";
          };
          "local" = {
            sopsFile = ./sops/ie.yaml;
            owner = "dylan";
          };
          "external" = {
            sopsFile = ./sops/ie.yaml;
            owner = "dylan";
          };
          "remote" = {
            sopsFile = ./sops/ie.yaml;
            owner = "dylan";
          };
          "disk_uuid" = {
            sopsFile = ./sops/ie.yaml;
            owner = "dylan";
          };
        };
      })

      (lib.mkIf (cfg.machineType == "vps") {
        sops.secrets =
          {
          };
      })
    ]
  );
}
