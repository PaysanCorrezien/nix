{ lib, inputs, config, pkgs, ... }:

let
  cfg = config.settings.sops;
in {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  options.settings = lib.mkOption {
    type = lib.types.submodule {
      options.sops = lib.mkOption {
        type = lib.types.submodule {
          options = {
            enableGlobal = lib.mkEnableOption "Enable global secrets";
            machineType = lib.mkOption {
              type = lib.types.enum [ "desktop" "homeserver" "vps" ];
              description = "Type of the machine (desktop, homeserver, or vps)";
            };
          };
        };
        default = {};
        description = "Sops-related settings";
      };
    };
    default = {};
  };

   config = lib.mkMerge [
    {
   environment.systemPackages = with pkgs; [ sops age ];
      sops = {
        defaultSopsFormat = "yaml";
        #NOTE: except a key name specific by host ? maybe find a more appropriate way than this now ? based on nixos.config hostname directly ?
        age.keyFile = "/var/lib/secrets/${cfg.machineType}.txt";
      };
    }


    (lib.mkIf cfg.enableGlobal {
      sops.secrets = {
        "tailscale_auth_key" = {
          sopsFile = ./sops/kumo.yaml;
          group = "root";
          mode = "0440";
        };
#NOTE: for home manager , but may be usefull on others host later
        "nextcloudUrl" = {
          sopsFile = ./sops/kumo.yaml;
          owner = "dylan";
        };
        # "wifi_homekey" = {
        #   sopsFile = ./sops/kumo.yaml;
        #   owner = "root";
        # };
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
        "thunderbird/account1/server" = {
          sopsFile = ./sops/pasokon.yaml;
          owner = "dylan";
        };
        "thunderbird/account1/port" = {
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
        "thunderbird/account2/server" = {
          sopsFile = ./sops/pasokon.yaml;
          owner = "dylan";
        };
        "thunderbird/account2/port" = {
          sopsFile = ./sops/pasokon.yaml;
          owner = "dylan";
        };
      };
    })

    (lib.mkIf (cfg.machineType == "homeserver") {
      sops.secrets = {
        # "homeserver_secret" = {
        #   sopsFile = ./sops/ie.yaml;
        #   owner = "dylan";
        # };
      };
    })

    (lib.mkIf (cfg.machineType == "vps") {
      sops.secrets = {
        # "vps_secret" = {
        #   sopsFile = ./sops/vps.yaml;
        #   owner = "dylan";
        # };
      };
    })
  ];
}
