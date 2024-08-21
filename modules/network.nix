{ config, lib, pkgs, ... }:
let
  cfg = config;
  tailscaleAuthKeyFile = config.sops.secrets.tailscale_auth_key.path;
in
{
  config = lib.mkIf (cfg.settings.tailscale.enable) {

    services.tailscale = {
      enable = true;
      openFirewall = true;
      interfaceName = "tailscale0";
      authKeyFile = tailscaleAuthKeyFile;
      extraUpFlags = [
        "--hostname=${cfg.networking.hostName}"
        "--advertise-tags=tag:nixos${
          lib.optionalString cfg.settings.isServer ",tag:server"
        }"
        "--accept-dns=true"
      ];
    };

    networking = {
      firewall = {
        trustedInterfaces = [ "tailscale0" ];
        allowedTCPPorts = [ 22 ];
      };
      interfaces.tailscale0.ipv4.addresses = [{
        address = cfg.settings.tailscaleIP;
        prefixLength = 32;
      }];
    };

    environment.systemPackages = [ pkgs.tailscale ];

    # Replace the warning with an assertion
    assertions = [{
      assertion = cfg.settings.tailscale.enable -> config.sops.secrets.tailscale_auth_key.path != null;
      message = "Tailscale is enabled but the auth key secret is not defined in sops. Please ensure 'tailscale_auth_key' is properly configured in your sops secrets.";
    }];
  };
}
