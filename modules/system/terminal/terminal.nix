{ config, pkgs, lib, ... }:

#NOTE: this only enable those extra if its not a server env
let isServer = config.settings.isServer;

in {
  imports = [ ./core/default.nix ./extra/default.nix ];

  config = {
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    settings.terminal.extras.enable = !isServer;
  };
}
