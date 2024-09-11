{ config, pkgs, lib, ... }:

let settings = config.settings;
in {

  # config = lib.mkIf (!config.settings.IsServer) {

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      KbdInteractiveAuthentication = false;
      X11Forwarding = false;
      AuthenticationMethods = "publickey";
      UsePAM = false;

    };
  };
  # };
}

