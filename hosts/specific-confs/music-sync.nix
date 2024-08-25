{ config, lib, pkgs, ... }:

let
  readSecretFile = file:
    lib.optionalString (builtins.pathExists file) (builtins.readFile file);
  nextcloudUrl = readSecretFile "/run/secrets/nextcloudUrl";
  nextcloudUsername = readSecretFile "/run/secrets/nextcloudUsername";
  sync_password = readSecretFile "/run/secrets/sync_password";
  discordWebhookUrl = readSecretFile "/run/secrets/discordWebhookUrl";
  sync_localDir = readSecretFile "/run/secrets/sync_localDir";
  sync_remoteDir = readSecretFile "/run/secrets/sync_remoteDir";
  sync_rcloneConfigFile = "/etc/rclone.conf";
  mountPoint = "/mnt/webdav";
  logFile = "/var/log/rclone-sync.log";
in {
  environment.systemPackages = [ pkgs.rclone ];

  environment.etc."rclone.conf".text = ''
    [webdav]
    type = webdav
    url = ${nextcloudUrl}/remote.php/dav/files/${nextcloudUsername}/
    vendor = nextcloud
    user = ${nextcloudUsername}
    pass = ${sync_password}
  '';

  systemd.services.rclone-sync = {
    description = "Rclone WebDAV bidirectional sync service";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    script = ''
      #!/bin/bash
      set -euo pipefail

      log() {
        echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> ${logFile}
      }

      notify_discord() {
        ${pkgs.curl}/bin/curl -H "Content-Type: application/json" \
          -d "{\"content\":\"$1\"}" ${discordWebhookUrl}
      }

      sync_and_log() {
        local direction=$1
        local source=$2
        local dest=$3
        
        log "Starting $direction sync"
        
        local backup_dir
        if [[ $direction == "remote to local" ]]; then
          backup_dir="/tmp/rclone_backup_$(date +%Y%m%d_%H%M%S)"
        else
          backup_dir="webdav:/Backups/rclone_backup_$(date +%Y%m%d_%H%M%S)"
        fi
        
        local sync_output
        sync_output=$(${pkgs.rclone}/bin/rclone sync "$source" "$dest" \
          --config ${sync_rcloneConfigFile} \
          --backup-dir "$backup_dir" \
          --suffix=-$(date +%Y%m%d_%H%M%S) \
          --bwlimit 5M \
          --stats-one-line \
          --stats-unit bytes \
          2>&1)

        local status=$?
        log "$sync_output"
        
        if [ $status -ne 0 ]; then
          notify_discord "Error in $direction sync: $sync_output"
        fi
      }

      sync_and_log "remote to local" "${sync_remoteDir}" "${sync_localDir}"
      sync_and_log "local to remote" "${sync_localDir}" "${sync_remoteDir}"
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
  
  systemd.services.rclone-sync-daily-summary = {
    description = "Rclone sync daily summary";
    script = ''
      #!/bin/bash
      set -euo pipefail

      summary=$(cat ${logFile} | ${pkgs.gawk}/bin/awk '
        BEGIN { print "Daily Rclone Sync Summary:" }
        /Starting remote to local sync/ { remote_to_local++ }
        /Starting local to remote sync/ { local_to_remote++ }
        /Error in/ { errors++ }
        END {
          print "Remote to Local syncs:", remote_to_local
          print "Local to Remote syncs:", local_to_remote
          print "Errors encountered:", errors
        }
      ')

      ${pkgs.curl}/bin/curl -H "Content-Type: application/json" \
        -d "{\"content\":\"$summary\"}" ${discordWebhookUrl}

      # Rotate log file
      mv ${logFile} ${logFile}.1
      touch ${logFile}
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };

  systemd.timers.rclone-sync = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*:0/15";
      Unit = "rclone-sync.service";
    };
  };

  systemd.timers.rclone-sync-daily-summary = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 04:00:00";
      Unit = "rclone-sync-daily-summary.service";
    };
  };

  system.activationScripts.createWebdavMountPoint = ''
    mkdir -p ${mountPoint}
    chown root:root ${mountPoint}
    chmod 755 ${mountPoint}
  '';

  fileSystems."/mnt/webdav" = {
    device = "webdav:/";
    fsType = "rclone";
    options = [
      "rw"
      "noauto"
      "user"
      "exec"
      "uid=1000"
      "gid=100"
      "_netdev"
      "config=${sync_rcloneConfigFile}"
    ];
  };
}
