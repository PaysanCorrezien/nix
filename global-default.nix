{ config, lib, ... }:

# TODO: find a way to removeall boileplate using nix magic
# for now i fail it doesnt output good structure
let
  globalDefaults = {
    username = lib.mkDefault "dylan";
    ip = lib.mkDefault "192.168.0.111";
    isServer = lib.mkDefault false;
    virtualisation.enable = lib.mkDefault false;
    environment = lib.mkDefault "home";
    isExperimental = lib.mkDefault false;
  };
in {
  options = {
    settings = {
      username = lib.mkOption {
        type = lib.types.str;
        default = globalDefaults.username;
        description = "Username for the system.";
      };
      ip = lib.mkOption {
        type = lib.types.str;
        default = globalDefaults.ip;
        description = "IP address for the system.";
      };
      isServer = lib.mkOption {
        type = lib.types.bool;
        default = globalDefaults.isServer;
        description = "Is it a server?";
      };
      virtualisation.enable = lib.mkOption {
        type = lib.types.bool;
        default = globalDefaults.virtualisation.enable;
        description = "Do I run VM on this host?";
      };
      environment = lib.mkOption {
        type = lib.types.enum [ "home" "work" ];
        default = globalDefaults.environment;
        description = "The environment setting (home or work).";
      };
      isExperimental = lib.mkOption {
        type = lib.types.bool;
        default = globalDefaults.isExperimental;
        description = "Is this an experimental machine?";
      };
    };
  };

  config.settings = {
    username = globalDefaults.username;
    ip = globalDefaults.ip;
    isServer = globalDefaults.isServer;
    virtualisation.enable = globalDefaults.virtualisation.enable;
    environment = globalDefaults.environment;
    isExperimental = globalDefaults.isExperimental;
  };
}
