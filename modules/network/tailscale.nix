# tailscale.nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.settings.tailscale;

  # Tag building helpers
  mkTag = tag: if lib.hasPrefix "tag:" tag then tag else "tag:${tag}";

  # Define all possible conditional tags in a clear structure
  conditionalTags = {
    server = {
      condition = config.settings.isServer or false;
      tag = "server";
    };
    rdp = {
      condition = config.settings.rdpserver.enable or false;
      tag = "rdp";
    };
  };

  # Convert conditional tags to a list based on conditions
  getEnabledTags =
    tags: lib.flatten (lib.mapAttrsToList (name: def: lib.optional def.condition def.tag) tags);

  # Build final tag list
  tags = {
    # Always present
    required = [ "nixos" ];
    # From settings
    custom = cfg.tags;
    # Conditional based on system state
    conditional = getEnabledTags conditionalTags;
  };

  # Combine all tags, ensure prefix, and create final string
  tagString = lib.pipe (tags.required ++ tags.custom ++ tags.conditional) [
    lib.unique
    (map mkTag)
    (lib.concatStringsSep ",")
  ];

  # Debug output
  debugOutput = builtins.trace ''
    Tag composition:
      Required: ${toString tags.required}
      Custom: ${toString tags.custom}
      Conditional: ${toString tags.conditional}
      Final: ${tagString}
  '' null;
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
    services.tailscale = {
      enable = true;
      interfaceName = "tailscale0";
      authKeyFile = config.sops.secrets.tailscale_auth_key.path;
      extraUpFlags = [
        "--hostname=${config.networking.hostName}"
        "--advertise-tags=${tagString}"
        "--accept-dns=true"
      ];
    };

    services.tailscale-ssh = {
      enable = true;
      sshPort = 22;
      interfaceName = "tailscale0";
    };

    warnings = [
      "Tailscale tags: ${tagString}"
    ];
  };
}
