{ config, lib, pkgs, ... }:

let
  cfg = config.settings.rdpserver;
  tailscaleCfg = config.settings.tailscale;
in
{
  options.settings = {
    rdpserver = lib.mkOption {
      type = lib.types.submodule {
        options = {
          enable = lib.mkEnableOption "Enable RDP on the host";
        };
      };
      default = { enable = false; };
      description = "RDP server settings";
    };
  };

  config = lib.mkIf (cfg.enable && tailscaleCfg.enable) {
    services.xrdp = {
      enable = true;
      openFirewall = false;  # We'll manage the firewall manually
      defaultWindowManager = "gnome-session";
    };

    # Add "rdp" tag to Tailscale when RDP is enabled
    settings.tailscale.tags = tailscaleCfg.tags ++ [ "rdp" ];

    # Allow RDP only via Tailscale interface
    networking.firewall = {
      enable = true;
      interfaces."tailscale0".allowedTCPPorts = [ 3389 ];
    };

    # Ensure xrdp only listens on the Tailscale interface
    services.xrdp.settings = {
      Globals = {
        ListenAddress = "tailscale0";
      };
    };

    assertions = [
      {
        assertion = cfg.enable -> tailscaleCfg.enable;
        message = "RDP server requires Tailscale to be enabled. Please enable Tailscale before enabling RDP.";
      }
    ];
  };
}
