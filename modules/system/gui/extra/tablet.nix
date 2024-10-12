{ config, pkgs, lib, ... }:

let cfg = config.settings.isServer;
in {
  config = lib.mkIf (!cfg) {

  hardware.opentabletdriver.enable = true;
};
}


