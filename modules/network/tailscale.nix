{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.settings.tailscale;

  # Helper function to ensure each tag is prefixed with "tag:" only once
  ensureTagPrefix = tag: if lib.hasPrefix "tag:" tag then tag else "tag:${tag}";

  # Combine all tags, ensuring proper prefixing
  allTags = lib.unique (
    (lib.optional config.settings.isServer "tag:server")
    ++ (map ensureTagPrefix ([ "nixos" ] ++ cfg.tags))
  );

  # Convert tags to a comma-separated string
  tagsString = lib.concatStringsSep "," allTags;

in
{
  options.settings.tailscale = {
    enable = lib.mkEnableOption "Enable Tailscale";
    tags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of tags to apply to this Tailscale node";
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable the tailscale-ssh module
    services.tailscale-ssh = {
      enable = true;
      # You can customize these if needed
      sshPort = 22;
      interfaceName = "tailscale0";
      # checkInterval = 300;
    };

    # Your existing tailscale configuration
    services.tailscale = {
      enable = true;
      # openFirewarl = true;
      interfaceName = "tailscale0";
      authKeyFile = config.sops.secrets.tailscale_auth_key.path;
      extraUpFlags = [
        "--hostname=${config.networking.hostName}"
        "--advertise-tags=${tagsString}"
        "--accept-dns=true"
      ];
    };

    assertions = [
      {
        assertion = cfg.enable -> config.sops.secrets.tailscale_auth_key.path != null;
        message = "Tailscale is enabled but the auth key secret is not defined in sops. Please ensure 'tailscale_auth_key' is properly configured in your sops secrets.";
      }
    ];
  };
}
