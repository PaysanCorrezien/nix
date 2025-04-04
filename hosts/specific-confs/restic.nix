{
  config,
  lib,
  pkgs,
  ...
}:
let
  username = config.settings.username;
  remoteBackupHost = "chi";
  sshKeyPath = "/home/${username}/.ssh/${remoteBackupHost}";
  remoteBackupPath = "/home/${username}/backups/docker";

  # Create a robust mount script

  discordNotifyScript = pkgs.writeScriptBin "notify-discord" ''
    #!${pkgs.bash}/bin/bash
    BACKUP_NAME="$1"
    STATUS="$2"
    DETAILS="$3"
    
    WEBHOOK_URL="$(cat /run/secrets/discordWebhookUrlBackup)"
    
    if [ -n "$WEBHOOK_URL" ]; then
      TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
      
      JSON_CONTENT=$(cat <<EOF
    {
      "embeds": [{
        "title": "$BACKUP_NAME Status",
        "color": $([ "$STATUS" = "success" ] && echo "65280" || echo "16711680"),
        "description": "$(echo "$DETAILS" | sed 's/"/\\"/g' | sed ':a;N;$!ba;s/\n/\\n/g')",
        "footer": {
          "text": "Backup attempted at $TIMESTAMP"
        }
      }]
    }
EOF
    )
      
      ${pkgs.curl}/bin/curl -H "Content-Type: application/json" \
        -d "$JSON_CONTENT" \
        "$WEBHOOK_URL"
    fi
  '';

  # Base configuration for all backups
  baseBackupConfig = {
    user = username;
    initialize = true;
    paths = [
      "/home/${config.settings.username}/docker"
      "/home/${config.settings.username}/music"
    ];
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 6"
    ];
    exclude = [
      "**/.tmp/**"
      "**/cache/**"
    ];
    runCheck = false;
    checkOpts = [ "--with-cache" ];
  };

  backupStatusCommand = name: ''
    BACKUP_STATUS=$?
    BACKUP_TYPE=""

    case "${name}" in
      "docker-backup-local")
        BACKUP_TYPE="Local Backup"
        ;;
      "docker-backup-external")
        BACKUP_TYPE="External Drive Backup"
        ;;
      "docker-backup-remote")
        BACKUP_TYPE="Remote Backup"
        ;;
    esac

    if [ -f "/tmp/mount-failed-${name}" ]; then
      ${discordNotifyScript}/bin/notify-discord "$BACKUP_TYPE" "failed" "Failed to mount external drive"
      rm "/tmp/mount-failed-${name}"
      exit 1
    fi

    if systemctl is-failed "restic-backups-${name}.service" >/dev/null 2>&1; then
      ERROR_LOG=$(journalctl -u "restic-backups-${name}.service" -n 50 --no-pager)
      MESSAGE="❌ Backup Failed"
      MESSAGE="$MESSAGE\nError Details:"
      MESSAGE="$MESSAGE\n\`\`\`\n$ERROR_LOG\n\`\`\`"
      ${discordNotifyScript}/bin/notify-discord "$BACKUP_TYPE" "failed" "$MESSAGE"
      exit 1
    fi

    SNAPSHOT_INFO=$(${pkgs.restic}/bin/restic snapshots --latest 5)

    MESSAGE="✅ Backup Successful"
    MESSAGE="$MESSAGE\n\nLatest Snapshots:\n"
    MESSAGE="$MESSAGE\n\`\`\`\n$SNAPSHOT_INFO\n\`\`\`"

    ${discordNotifyScript}/bin/notify-discord "$BACKUP_TYPE" "success" "$MESSAGE"
  '';

in
{
  # Ensure required directories exist
  systemd.tmpfiles.rules = [
    "d /var/lib/restic 0700 ${username} users -"
    "d /mnt/external_drive 0755 root root -"
    "d /var/backup 0755 ${username} users"
    "d /var/backup/docker 0755 ${username} users"
    "d /run/restic-backups-docker-backup-external 0755 root root -"
    "f /var/log/usb_drive_operations.log 0644 root root -"
  ];

  environment.systemPackages = [ discordNotifyScript ];

  # Add shell aliases using SOPS-managed passwords
  environment.interactiveShellInit = ''
  function localbackup() {
    restic -r /var/backup/docker --password-file /run/secrets/local "$@"
  }
  
  function extbackup() {
    restic -r /mnt/external_drive/backups/docker --password-file /run/secrets/external "$@"
  }
'';

  services.restic.backups = {
    # Local backup configuration
    docker-backup-local = baseBackupConfig // {
      repository = "/var/backup/docker";
      passwordFile = "/run/secrets/local";
      timerConfig = {
        OnCalendar = "2:00";
        RandomizedDelaySec = "30m";
        Persistent = true;
      };
      backupCleanupCommand = backupStatusCommand "docker-backup-local";
    };


       docker-backup-external = baseBackupConfig // {
      repository = "/mnt/external_drive/backups/docker";
      passwordFile = "/run/secrets/external";
      runCheck = false;
      timerConfig = {
        OnCalendar = "3:15";
        RandomizedDelaySec = "30m";
        Persistent = true;
      };
       backupCleanupCommand = ''
        echo "=== Starting backup cleanup ==="
        ${backupStatusCommand "docker-backup-external"}
        if ${pkgs.util-linux}/bin/mountpoint -q "/mnt/external_drive"; then
          sudo ${pkgs.util-linux}/bin/umount /mnt/external_drive || true
          sudo ${pkgs.hdparm}/bin/hdparm -y /dev/sdc || true
        fi
      '';
    };
};

systemd.services."restic-backups-docker-backup-external" = {
    after = [ "backup-drive-mount.service" ];
    requires = [ "backup-drive-mount.service" ];
    serviceConfig = {
      User = lib.mkForce "root";
      Group = lib.mkForce "root";
      SupplementaryGroups = [ "docker" ];
    };
};
}
