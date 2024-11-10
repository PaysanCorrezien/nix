#TODO: sops all these infos : pass / url / ids / refactor sops to make a clearer separation of creds
#TODO: make a more direct somewhere else bin mount/ unmount on UID that can be callled by the aliases
#FIX: aliases
#FIX: SECURITY : mount perm ? 
#TODO: otpimise logic 
#TODO: improve notification : snapshots number, and success sometimes when it actaully fail
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
  mountScript = pkgs.writeScriptBin "mount-backup-drive" ''
    #!${pkgs.bash}/bin/bash

    DEVICE="/dev/sdc"
    UUID="$(cat /var/run/secrets/disk_uuid)"
    LABEL="SAMSUNG"
    MOUNT_POINT="/mnt/external_drive"
    LOG_FILE="/var/log/usb_drive_operations.log"

    # Ensure log directory exists
    mkdir -p "$(dirname "$LOG_FILE")"

    log_message() {
      echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
    }

    is_mounted() {
      ${pkgs.util-linux}/bin/mountpoint -q "$MOUNT_POINT"
    }

    mount_drive() {
      log_message "Attempting to mount backup drive..."
      
      # Power up the drive if in standby
      if ${pkgs.hdparm}/bin/hdparm -C "$DEVICE" 2>/dev/null | grep -q "standby"; then
        log_message "Powering up drive..."
        ${pkgs.hdparm}/bin/hdparm -S 0 "$DEVICE"
        # Give the drive time to spin up
        sleep 5
      fi
      
      # Create mount point if needed
      ${pkgs.coreutils}/bin/mkdir -p "$MOUNT_POINT"
      
      # Try mounting by UUID first with specific ntfs-3g options
      if ${pkgs.util-linux}/bin/mount -U "$UUID" -t ntfs3 -o uid=0,gid=0,fmask=0133,dmask=0022 "$MOUNT_POINT"; then
        # Wait for mount to complete and verify
        for i in {1..30}; do
          if ${pkgs.util-linux}/bin/mountpoint -q "$MOUNT_POINT" && \
             [ -d "$MOUNT_POINT" ] && \
             ${pkgs.coreutils}/bin/ls "$MOUNT_POINT" >/dev/null 2>&1; then
            log_message "Drive mounted successfully by UUID at $MOUNT_POINT"
            ${pkgs.coreutils}/bin/mkdir -p "$MOUNT_POINT/backups/docker"
            # Extra validation
            if [ -d "$MOUNT_POINT/backups/docker" ]; then
              sleep 2  # Final wait to ensure filesystem is ready
              return 0
            fi
          fi
          sleep 1
        done
        log_message "Mount succeeded but directory access failed"
        return 1
      fi
      
      # Try mounting by LABEL if UUID fails
      log_message "UUID mount failed, attempting mount by LABEL..."
      if ${pkgs.util-linux}/bin/mount -L "$LABEL" -t ntfs3 -o uid=0,gid=0,fmask=0133,dmask=0022 "$MOUNT_POINT"; then
        # Wait for mount to complete and verify
        for i in {1..30}; do
          if ${pkgs.util-linux}/bin/mountpoint -q "$MOUNT_POINT" && \
             [ -d "$MOUNT_POINT" ] && \
             ${pkgs.coreutils}/bin/ls "$MOUNT_POINT" >/dev/null 2>&1; then
            log_message "Drive mounted successfully by LABEL at $MOUNT_POINT"
            ${pkgs.coreutils}/bin/mkdir -p "$MOUNT_POINT/backups/docker"
            # Extra validation
            if [ -d "$MOUNT_POINT/backups/docker" ]; then
              sleep 2  # Final wait to ensure filesystem is ready
              return 0
            fi
          fi
          sleep 1
        done
        log_message "Mount succeeded but directory access failed"
        return 1
      fi
      
      # If both mount attempts fail
      log_message "Failed to mount backup drive"
      touch /tmp/mount-failed-docker-backup-external
      return 1
    }

    unmount_drive() {
      log_message "Attempting to unmount backup drive..."
      
      if ${pkgs.util-linux}/bin/umount "$MOUNT_POINT"; then
        log_message "Drive unmounted successfully"
        # Power down the drive
        ${pkgs.hdparm}/bin/hdparm -y "$DEVICE" || log_message "Failed to power down drive"
        return 0
      else
        log_message "Failed to unmount drive"
        return 1
      fi
    }

    # Main logic
    if ! is_mounted; then
      mount_drive
    fi
  '';

  discordNotifyScript = pkgs.writeScriptBin "notify-discord" ''
        #!${pkgs.bash}/bin/bash
        BACKUP_NAME="$1"
        STATUS="$2"
        DETAILS="$3"
        
        WEBHOOK_URL=$(cat /home/dylan/.restic-webhook.txt)
        
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

  # Add hdparm to system packages
  environment.shellAliases = {
    # Local backup commands
    localbackup = "restic -r /var/backup/docker --password-file /var/lib/restic/local.txt";
    extbackup = "restic -r /mnt/external_drive/backups/docker --password-file /var/lib/restic/external.txt";
  };

  services.restic.backups = {
    # Local backup configuration
    docker-backup-local = baseBackupConfig // {
      repository = "/var/backup/docker";
      passwordFile = "/var/lib/restic/local.txt";
      timerConfig = {
        OnCalendar = "2:00";
        RandomizedDelaySec = "30m";
        Persistent = true;
      };
      backupCleanupCommand = backupStatusCommand "docker-backup-local";
    };

    # External drive backup configuration
    docker-backup-external = baseBackupConfig // {
      repository = "/mnt/external_drive/backups/docker";
      passwordFile = "/var/lib/restic/external.txt";
      runCheck = false;
      timerConfig = {
        OnCalendar = "3:00";
        RandomizedDelaySec = "30m";
        Persistent = true;
      };
      user = "root";
      backupPrepareCommand = ''
        # Mount the drive
        ${mountScript}/bin/mount-backup-drive

        # Verify the repository is accessible
        if [ ! -f "/mnt/external_drive/backups/docker/config" ]; then
          echo "Repository config not found or not accessible"
          touch /tmp/mount-failed-docker-backup-external
          exit 1
        fi

        # Fix permissions if needed
        ${pkgs.coreutils}/bin/chown -R root:root /mnt/external_drive/backups/docker
        ${pkgs.coreutils}/bin/chmod -R u+rwX,g+rX,o+rX /mnt/external_drive/backups/docker
      '';
      backupCleanupCommand = ''
        # Run the standard status command
        ${backupStatusCommand "docker-backup-external"}

        # Then unmount the drive if it's mounted
        if ${pkgs.util-linux}/bin/mountpoint -q "/mnt/external_drive"; then
          ${pkgs.util-linux}/bin/umount /mnt/external_drive || true
          # Attempt to power down the drive
          ${pkgs.hdparm}/bin/hdparm -y /dev/sdc || true
        fi
      '';
    };
  };

  # Prometheus exporter configuration
  #TEST: check how this work , probablby one export by type needed ?
  services.prometheus.exporters.restic = {
    enable = true;
    refreshInterval = 3600; # 1 hour in seconds
    repository = "/var/backup/docker";
    passwordFile = "/var/lib/restic/local.txt";
    extraFlags = [
      "--repository=/var/backup/docker#$(cat /var/lib/restic/local.txt)"
      "--repository=/mnt/external_drive/backups/docker#$(cat /var/lib/restic/external.txt)"
    ];
  };
}
