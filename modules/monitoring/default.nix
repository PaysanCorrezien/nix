{ config, lib, pkgs, ... }:


with lib;

let
  cfg = config.settings.monitoring;
  centralServer = "homeserv";
in {
  options.settings.monitoring = {
    enable = mkEnableOption "Enable monitoring services (Node Exporter and Promtail)";
  };

  config = mkIf cfg.enable {
    services.prometheus.exporters.node = {
      enable = true;
      enabledCollectors = [ "systemd" ];
      port = 9100;
    };


    services.promtail = {
      enable = true;
      configuration = {
        server = {
          http_listen_port = 28183;
        };
        positions = {
          filename = "/var/lib/promtail/positions.yaml";
        };
        clients = [{
          url = "http://${centralServer}:3100/loki/api/v1/push";
        }];
        scrape_configs = [
          {
            job_name = "journal";
            journal = {
              path = "/var/log/journal";
              max_age = "24h";
              labels = {
                job = "systemd-journal";
                host = config.networking.hostName;
              };
            };
            relabel_configs = [{
              source_labels = ["__journal__systemd_unit"];
              target_label = "unit";
            }];
          }
          #NOTE: this parse the log with a format easy to use and query in grafana to quiclky check SSH
          #TODO: create a promtail task do the same for logon and logoff
          {
            job_name = "sshd";
            journal = {
              path = "/var/log/journal";
              max_age = "24h";
              labels = {
                job = "secure";
                env = "dev";
                host = config.networking.hostName;
              };
            };
            relabel_configs = [
              {
                action = "keep";
                source_labels = ["__journal__systemd_unit"];
                regex = "sshd.service|ssh.service";
              }
              {
                source_labels = ["__journal__systemd_unit"];
                target_label = "unit";
              }
              {
                source_labels = ["__journal__hostname"];
                target_label = "instance";
              }
            ];
            pipeline_stages = [
              {
                regex = {
                  expression = "^(?P<timestamp>\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}\\.\\d{3})\\n(?P<message>.*)";
                };
              }
              {
                timestamp = {
                  source = "timestamp";
                  format = "2006-01-02 15:04:05.000";
                };
              }
              {
                regex = {
                  expression = "^(?P<action>\\w+).*for (?P<username>\\w+) from (?P<src_ip>\\S+) port (?P<src_port>\\d+)";
                };
              }
              {
                regex = {
                  expression = "^(?P<action>Disconnected) from user (?P<username>\\w+) (?P<src_ip>\\S+) port (?P<src_port>\\d+)";
                };
              }
              {
                regex = {
                  expression = "^(?P<action>Received disconnect) from (?P<src_ip>\\S+) port (?P<src_port>\\d+)";
                };
              }
              {
                regex = {
                  expression = "^Connection closed by (?P<action>authenticating user) (?P<username>\\w+) (?P<src_ip>\\S+) port (?P<src_port>\\d+) \\[(?P<auth_stage>\\w+)\\]";
                };
              }
              {
                labels = {
                  action = "";
                  username = "";
                  src_ip = "";
                  src_port = "";
                  auth_stage = "";
                };
              }
            ];
          }
        ];
      };
    };
    systemd.tmpfiles.rules = [
  "d /var/lib/promtail 0755 promtail promtail -"
];

    # Open firewall for Node Exporter only from Tailscale network
        networking.firewall = {
      enable = true;
      extraCommands = ''
        # Allow access to Node Exporter (9100) only from Tailscale network
        iptables -A INPUT -i tailscale0 -p tcp --dport 9100 -j ACCEPT
      '';
      extraStopCommands = ''
        # Clean up rules when stopping the firewall
        iptables -D INPUT -i tailscale0 -p tcp --dport 9100 -j ACCEPT || true
      '';
    };

  };
}
