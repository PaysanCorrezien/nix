# Keeping most of the config the same, just updating the backupStatusCommand
{
  config,
  lib,
  pkgs,
  ...
}:
let
  username = config.settings.username;
  resticEnvPath = "/home/${username}/.restic.env";
  passwordFileExists = builtins.pathExists resticEnvPath;
  remoteBackupHost = "chi"; # Declaring the remote host variable
  sshKeyPath = "/home/${username}/.ssh/${remoteBackupHost}";
  remoteBackupPath = "/home/${username}/backups/docker"; # Generic backup location on remote

  discordNotifyScript = pkgs.writeScriptBin "notify-discord" ''
    #!${pkgs.bash}/bin/bash
    BACKUP_NAME="$1"
    STATUS="$2"
    DETAILS="$3"

    # Source the env file to get the webhook URL
    source ${resticEnvPath}

    if [ -n "$DISCORD_WEBHOOK_URL" ]; then
      TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
      
      # Create JSON payload with proper escaping
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
        "$DISCORD_WEBHOOK_URL"
    fi
  '';

  # Helper script to extract password from env file
  mkPasswordScript =
    passwordVar:
    toString (
      pkgs.writeScript "get-password-${passwordVar}" ''
        #!${pkgs.bash}/bin/bash
        source ${resticEnvPath}
        echo "''${${passwordVar}}"
      ''
    );

  # Create password files for each backup
  localPasswordFile = mkPasswordScript "RESTIC_LOCAL_PASSWORD";
  externalPasswordFile = mkPasswordScript "RESTIC_EXTERNAL_PASSWORD";
  remotePasswordFile = mkPasswordScript "RESTIC_REMOTE_PASSWORD";

  # Base configuration for all backups
  baseBackupConfig = {
    user = username;
    initialize = true;
    paths = [ "/home/${config.settings.username}/docker" ];
    environmentFile = resticEnvPath;
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

    # Get backup information with proper environment
    source ${resticEnvPath}
    LATEST_SNAPSHOT_ID=$(${pkgs.restic}/bin/restic snapshots --latest 1 --json | ${pkgs.jq}/bin/jq -r '.[0].id')
    SNAPSHOT_INFO=$(${pkgs.restic}/bin/restic snapshots --latest 5)

    MESSAGE="✅ Backup Successful"
    MESSAGE="$MESSAGE\n\nLatest Snapshots:\n"
    MESSAGE="$MESSAGE\n\`\`\`\n$SNAPSHOT_INFO\n\`\`\`"

    ${discordNotifyScript}/bin/notify-discord "$BACKUP_TYPE" "success" "$MESSAGE"
  '';

in
{
  systemd.tmpfiles.rules = [
    "d /mnt/external_drive 0755 root root -"
    "d /var/backup 0755 ${username} users"
    "d /var/backup/docker 0755 ${username} users"
    "d /run/restic-backups-docker-backup-external 0755 root root -"
  ];

  services.restic.backups = lib.mkIf passwordFileExists {
    # Local backup configuration
    docker-backup-local = baseBackupConfig // {
      repository = "/var/backup/docker";
      passwordFile = localPasswordFile;
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
      passwordFile = externalPasswordFile;
      runCheck = false;
      timerConfig = {
        OnCalendar = "3:00";
        RandomizedDelaySec = "30m";
        Persistent = true;
      };
      user = "root";
      backupPrepareCommand = ''
        if ! ${pkgs.util-linux}/bin/mountpoint -q "/mnt/external_drive"; then
          ${pkgs.coreutils}/bin/mkdir -p /mnt/external_drive
          ${pkgs.util-linux}/bin/mount -t ntfs3 /dev/sde1 /mnt/external_drive || {
            touch /tmp/mount-failed-docker-backup-external
            exit 1
          }
        fi
        ${pkgs.coreutils}/bin/mkdir -p /mnt/external_drive/backups/docker
      '';
      backupCleanupCommand = ''
        # Run the standard status command
        ${backupStatusCommand "docker-backup-external"}

        # Then unmount after everything is done
        if ${pkgs.util-linux}/bin/mountpoint -q "/mnt/external_drive"; then
          ${pkgs.util-linux}/bin/umount /mnt/external_drive
        fi
      '';
    };

    # Remote backup configuration via SSH
    # TODO: generate a no passphrase ssh key for this
    #   docker-backup-remote = baseBackupConfig // {
    #     repository = "sftp:${username}@${remoteBackupHost}:${remoteBackupPath}";
    #     passwordFile = remotePasswordFile;
    #     timerConfig = {
    #       OnCalendar = "4:00";
    #       RandomizedDelaySec = "30m";
    #       Persistent = true;
    #     };
    #     extraBackupArgs = [
    #       "--one-file-system"
    #       "--compression max"
    #       "--option sftp.command='ssh -i ${sshKeyPath} -F none'"
    #     ];
    #     backupCleanupCommand = backupStatusCommand "docker-backup-remote";
    #   };
  };

  # Prometheus exporter configuration at root level
  services.prometheus = {
    exporters = {
      restic = {
        enable = true;
        refreshInterval = 3600; # 1 hour in seconds
        environmentFile = "${resticEnvPath}";
        repository = "/var/backup/docker"; # Set default repository
        passwordFile = localPasswordFile;
        extraFlags = [
          # Monitor all repositories with their respective passwords
          "--repository=/var/backup/docker#$(source ${resticEnvPath} && echo $RESTIC_LOCAL_PASSWORD)"
          "--repository=/mnt/external_drive/backups/docker#$(source ${resticEnvPath} && echo $RESTIC_EXTERNAL_PASSWORD)"
          # "--repository=sftp:${username}@${remoteBackupHost}:${remoteBackupPath}#$(source ${resticEnvPath} && echo $RESTIC_REMOTE_PASSWORD)"
        ];
      };
    };
  };
}
