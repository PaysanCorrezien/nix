{ config, lib, ... }:

# TODO: find a way to removeall boileplate using nix magic
# for now i fail it doesnt output good structure
let
  globalDefaults = {
    username = lib.mkDefault "dylan";
    ip = lib.mkDefault "192.168.0.111";
    isServer = lib.mkDefault false;
  };
in
{
  options = {
    settings.username = lib.mkOption {
      type = lib.types.str;
      default = globalDefaults.username;
      description = "Username for the system.";
    };

    settings.ip = lib.mkOption {
      type = lib.types.str;
      default = globalDefaults.ip;
      description = "IP address for the system.";
    };

    settings.isServer = lib.mkOption {
      type = lib.types.bool;
      default = globalDefaults.isServer;
      description = "Is it a server?";
    };
  };

  config.settings.username = globalDefaults.username;
  config.settings.ip = globalDefaults.ip;
  config.settings.isServer = globalDefaults.isServer;
}

