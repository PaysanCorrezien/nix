{ config, lib, pkgs, ... }:

let
  cfg = config.settings.tailscale;

  # Helper function to ensure each tag is prefixed with "tag:" only once
  ensureTagPrefix = tag: if lib.hasPrefix "tag:" tag then tag else "tag:${tag}";

  # Combine all tags, ensuring proper prefixing
  allTags = lib.unique (
    (lib.optional config.settings.isServer "tag:server") ++
    (map ensureTagPrefix (["nixos"] ++ cfg.tags))
  );

  # Convert tags to a comma-separated string
  tagsString = lib.concatStringsSep "," allTags;

in
{
  options.settings.tailscale = {
    enable = lib.mkEnableOption "Enable Tailscale";
    tags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "List of tags to apply to this Tailscale node";
    };
  };

  config = lib.mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      openFirewall = true;
      interfaceName = "tailscale0";
      authKeyFile = config.sops.secrets.tailscale_auth_key.path;
      extraUpFlags = [
        "--hostname=${config.networking.hostName}"
        "--advertise-tags=${tagsString}"
        "--accept-dns=true"
      ];
    };

    networking.firewall = {
      enable = true;
      trustedInterfaces = [ "tailscale0" ];
      allowedTCPPorts = [ 22 ]; # We'll dynamically manage this
    };

    environment.systemPackages = with pkgs; [
      tailscale
      jq
      iproute2
      iptables
    ];
    systemd.services.tailscale-firewall = {
      description = "Manage SSH firewall rules based on Tailscale status";
      after = [ "network.target" "tailscaled.service" ];
      wantedBy = [ "multi-user.target" ];
      path = with pkgs; [ jq iproute2 iptables tailscale gawk ];
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = "10s";
      };
      script = ''
        log() {
          echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
        }

        rule_exists() {
          iptables -C $@ 2>/dev/null
        }

        apply_rule() {
          local action=$1
          shift
          if ! rule_exists $@; then
            if $action $@ 2>/dev/null; then
              log "Applied: $action $@"
            else
              log "Failed to apply: $action $@ (Unexpected error)"
            fi
          else
            if [[ "$action" == *"-A"* || "$action" == *"-I"* ]]; then
              log "Rule already exists: $@"
            elif [[ "$action" == *"-D"* ]]; then
              if $action $@ 2>/dev/null; then
                log "Removed existing rule: $@"
              else
                log "Failed to remove existing rule: $@ (Unexpected error)"
              fi
            fi
          fi
        }

        get_default_interface() {
          ip route | awk '/default/ {print $5; exit}'
        }

              update_firewall() {
          local current_status=$1
          local previous_status=$2
          local default_interface=$(get_default_interface)

          log "Checking Tailscale status. Current: $current_status, Previous: $previous_status"

          if [ "$current_status" != "$previous_status" ]; then
            if [ "$current_status" = "true" ]; then
              log "Tailscale is up. Restricting SSH to Tailscale interface."
              apply_rule "iptables -D INPUT" "-p tcp --dport 22 -j ACCEPT"
              apply_rule "iptables -I INPUT" "-i tailscale0 -p tcp --dport 22 -j ACCEPT"
              apply_rule "iptables -A INPUT" "-p tcp --dport 22 -j DROP"
            else
              log "Tailscale is down. Allowing SSH on all interfaces."
              apply_rule "iptables -D INPUT" "-p tcp --dport 22 -j DROP"
              apply_rule "iptables -D INPUT" "-i tailscale0 -p tcp --dport 22 -j ACCEPT"
              apply_rule "iptables -I INPUT" "-p tcp --dport 22 -j ACCEPT"
            fi
            log "SSH rules updated. Default interface: ''${default_interface:-Not detected}, Tailscale interface: tailscale0"
          elif [ -z "$previous_status" ]; then
            if [ "$current_status" = "true" ]; then
              log "Initial state: Tailscale is up"
            else
              log "Initial state: Tailscale is down"
            fi
          else
            log "No change in Tailscale status. No action taken."
          fi
        }

        log "Starting Tailscale firewall management service"
        previous_status=""
        check_count=0

        while true; do
          current_status=$(tailscale status --json | jq -r '.BackendState == "Running"')
          update_firewall "$current_status" "$previous_status"
          previous_status=$current_status
          check_count=$((check_count + 1))
          log "Completed check #$check_count. Sleeping for 5 minutes."
          sleep 300
        done
      '';
    };

      assertions = [{
      assertion = cfg.enable -> config.sops.secrets.tailscale_auth_key.path != null;
      message = "Tailscale is enabled but the auth key secret is not defined in sops. Please ensure 'tailscale_auth_key' is properly configured in your sops secrets.";
    }];
  };
}
