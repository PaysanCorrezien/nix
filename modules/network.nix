{ config, lib, pkgs, ... }:
let
  cfg = config;
  tailscaleAuthKeyFile = "/run/secrets/tailscale_auth_key";
in {
  config = lib.mkIf (cfg.settings.tailscale.enable) {
    services.tailscale = {
      enable = true;
      openFirewall = true;
      interfaceName = "tailscale0";
      authKeyFile = tailscaleAuthKeyFile;
      extraUpFlags = [
        # "--ssh"
        "--hostname=${cfg.networking.hostName}"
        "--advertise-tags=tag:nixos${
          lib.optionalString cfg.settings.isServer ",tag:server"
        }"
        # Enable Tailscale DNS for hostname resolution
        "--accept-dns=true"
        # Commented out for potential future use:
        # "--advertise-exit-node"
        # "--advertise-routes=${cfg.settings.tailscaleIP}/32"
      ];
    };

    networking = {
      firewall = {
        trustedInterfaces = [ "tailscale0" ];
        # Open port for SSH over Tailscale
        allowedTCPPorts = [ 22 ];
      };
      # Set the Tailscale IP
      interfaces.tailscale0.ipv4.addresses = [{
        address = cfg.settings.tailscaleIP;
        prefixLength = 32;
      }];
    };

    environment.systemPackages = [ pkgs.tailscale ];

    # Enable SSH server
    services.openssh = {
      enable = true;
      # Only allow SSH connections over Tailscale
      listenAddresses = [{
        addr = cfg.settings.tailscaleIP;
        port = 22;
      }];
    };

    # Add an assertion to ensure the auth key file exists when Tailscale is enabled
    assertions = [{
      assertion = cfg.settings.tailscale.enable
        -> (builtins.pathExists tailscaleAuthKeyFile);
      message =
        "Tailscale is enabled but the auth key file is missing. Please ensure ${tailscaleAuthKeyFile} exists.";
    }];
  };
}
