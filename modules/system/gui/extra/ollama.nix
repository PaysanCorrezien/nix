{ config, pkgs, lib, ... }:

let cfg = config.settings.ai.enable;
in {

  config = lib.mkIf (!cfg) {

    services.ollama = { enable = true; };
  };
}
