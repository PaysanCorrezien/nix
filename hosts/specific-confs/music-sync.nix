{ config, lib, pkgs, ... }:

let
  readSecretFile = file:
    lib.optionalString (builtins.pathExists file) (builtins.readFile file);
  nextcloudUrl = readSecretFile "/run/secrets/nextcloudUrl";
  nextcloudUsername = readSecretFile "/run/secrets/nextcloudUsername";
  sync_password = readSecretFile "/run/secrets/nextcloudPassword";
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
        echo "$(date '+%Y-%m-%d %H:%M:%S') $1" | tee -a ${logFile}
      }

      notify_discord() {
        ${pkgs.curl}/bin/curl -H "Content-Type: application/json" \
          -d "{\"content\":\"$1\"}" ${discordWebhookUrl} || true
      }

      sync_and_log() {
        local direction=$1
        local source=$2
        local dest=$3
        
        log "Starting $direction sync from $source to $dest"
        
        # Create backup directory for deleted/changed files
        local backup_dir
        if [[ $direction == "remote to local" ]]; then
          backup_dir="/tmp/rclone_backup_$(date +%Y%m%d_%H%M%S)"
          mkdir -p "$backup_dir"
        else
          backup_dir="webdav:/Backups/rclone_backup_$(date +%Y%m%d_%H%M%S)"
        fi
        
        # Run sync with detailed logging
        local sync_output
        sync_output=$(${pkgs.rclone}/bin/rclone copy "$source" "$dest" \
          --config ${sync_rcloneConfigFile} \
          --backup-dir "$backup_dir" \
          --suffix=-$(date +%Y%m%d_%H%M%S) \
          --bwlimit 5M \
          --progress \
          --stats 30s \
          --stats-one-line \
          --stats-unit bytes \
          --verbose \
          --log-level INFO \
          2>&1)

        local status=$?
        
        # Log detailed statistics
        log "Sync Details for $direction:"
        log "$sync_output"
        
        # Check for specific error conditions
        if [ $status -ne 0 ]; then
          local error_msg="Error in $direction sync (exit code $status): $sync_output"
          log "ERROR: $error_msg"
          notify_discord "⚠️ $error_msg"
          return 1
        fi

        # Log successful completion with stats
        local success_msg="Successfully completed $direction sync"
        log "$success_msg"
        notify_discord "✅ $success_msg"
      }

      # Run both syncs with error handling
      if ! sync_and_log "remote to local" "${sync_remoteDir}" "${sync_localDir}"; then
        log "Remote to local sync failed, skipping local to remote sync"
        exit 1
      fi

      if ! sync_and_log "local to remote" "${sync_localDir}" "${sync_remoteDir}"; then
        log "Local to remote sync failed"
        exit 1
      fi

      log "Bidirectional sync completed successfully"
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      # Add timeout to prevent hanging
      TimeoutStartSec = "1800";
      # Ensure clean environment
      RuntimeDirectory = "rclone-sync";
      WorkingDirectory = "/var/lib/rclone-sync";
      # Add restart policy
      Restart = "on-failure";
      RestartSec = "60";
    };
  };
  
  systemd.services.rclone-sync-daily-summary = {
    description = "Rclone sync daily summary";
    script = ''
      #!/bin/bash
      set -euo pipefail

      summary=$(cat ${logFile} | ${pkgs.gawk}/bin/awk '
        BEGIN { 
          print "📊 *Daily Rclone Sync Summary:*" 
          remote_to_local = 0
          local_to_remote = 0
          errors = 0
          bytes_transferred = 0
        }
        /Starting remote to local sync/ { remote_to_local++ }
        /Starting local to remote sync/ { local_to_remote++ }
        /ERROR:/ { errors++ }
        /Transferred:/ { 
          match($0, /Transferred: .* ([0-9.]+) ([KMG]?Bytes)/, arr)
          if (arr[1] != "") {
            size = arr[1]
            unit = arr[2]
            if (unit == "KBytes") size *= 1024
            if (unit == "MBytes") size *= 1024*1024
            if (unit == "GBytes") size *= 1024*1024*1024
            bytes_transferred += size
          }
        }
        END {
          print "🔄 Remote to Local syncs:", remote_to_local
          print "🔄 Local to Remote syncs:", local_to_remote
          print "❌ Errors encountered:", errors
          print sprintf("📦 Total data transferred: %.2f GB", bytes_transferred/(1024*1024*1024))
        }
      ')

      ${pkgs.curl}/bin/curl -H "Content-Type: application/json" \
        -d "{\"content\":\"$summary\"}" ${discordWebhookUrl}

      # Rotate log file with timestamp
      mv ${logFile} ${logFile}.$(date +%Y%m%d)
      touch ${logFile}
      chmod 644 ${logFile}
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };

  # Rest of the configuration remains the same
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
