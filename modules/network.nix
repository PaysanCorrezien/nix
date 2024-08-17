{ config, lib, pkgs, ... }:
let
  cfg = config;
  tailscaleAuthKeyFile = "/run/secrets/tailscale_auth_key";
  readSecretFile = file:
    lib.optionalString (builtins.pathExists file) (builtins.readFile file);
  tailscaleAuthKey = readSecretFile tailscaleAuthKeyFile;
in {
  config = lib.mkIf (cfg.settings.tailscale.enable) {
    services.tailscale = {
      enable = true;
      openFirewall = true;
      interfaceName = "tailscale0";
      authKeyFile = lib.mkIf (tailscaleAuthKey != "") tailscaleAuthKeyFile;
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
        allowedTCPPorts = [ 22 ];
      };
      interfaces.tailscale0.ipv4.addresses = [{
        address = cfg.settings.tailscaleIP;
        prefixLength = 32;
      }];
    };
    environment.systemPackages = [ pkgs.tailscale ];
    services.openssh = {
      enable = true;
      listenAddresses = [{
        addr = cfg.settings.tailscaleIP;
        port = 22;
      }];
    };
    # Replace the assertion with a warning
    warnings =
      lib.optional (cfg.settings.tailscale.enable && tailscaleAuthKey == "")
      "Tailscale is enabled but the auth key file is missing or empty. Please ensure ${tailscaleAuthKeyFile} exists and contains a valid auth key.";
  };
}
