{ config
, lib
, pkgs
, ...
}:
let
  mountScript = pkgs.writeScriptBin "mount-backup-drive" ''
    #!${pkgs.bash}/bin/bash

    DEVICE="/dev/sdc"
    UUID="$(cat /run/secrets/disk_uuid)"
    LABEL="SAMSUNG"
    MOUNT_POINT="/mnt/external_drive"
    LOG_FILE="/var/log/usb_drive_operations.log"
    BACKUP_DIR="$MOUNT_POINT/backups/docker"

    # Ensure log directory exists
    mkdir -p "$(dirname "$LOG_FILE")"

    log_message() {
      local level="$1"
      local message="$2"
      echo "$(date '+%Y-%m-%d %H:%M:%S') [$level] - $message" >> "$LOG_FILE"
      # Also print to stderr for systemd journal
      echo "$(date '+%Y-%m-%d %H:%M:%S') [$level] - $message" >&2
    }

    check_device() {
      if ! [ -b "$DEVICE" ]; then
        log_message "ERROR" "Device $DEVICE not found"
        return 1
      fi
      
      local device_info=$(${pkgs.util-linux}/bin/lsblk -no SIZE,LABEL,UUID "$DEVICE" 2>/dev/null)
      log_message "INFO" "Device info: $device_info"
      return 0
    }

    is_mounted() {
      if ${pkgs.util-linux}/bin/mountpoint -q "$MOUNT_POINT"; then
        log_message "INFO" "Drive is already mounted at $MOUNT_POINT"
        return 0
      fi
      return 1
    }

    verify_mount() {
      local attempt=1
      local max_attempts=30
      
      while [ $attempt -le $max_attempts ]; do
        log_message "INFO" "Verifying mount attempt $attempt/$max_attempts..."
        
        if ! ${pkgs.util-linux}/bin/mountpoint -q "$MOUNT_POINT"; then
          log_message "ERROR" "Mount point verification failed - not a mount point"
          return 1
        fi
        
        if ! [ -d "$MOUNT_POINT" ]; then
          log_message "ERROR" "Mount point directory doesn't exist"
          return 1
        fi
        
        if ! ${pkgs.coreutils}/bin/ls "$MOUNT_POINT" >/dev/null 2>&1; then
          log_message "ERROR" "Cannot list mount point contents"
          sleep 1
          attempt=$((attempt + 1))
          continue
        fi
        
        # Try to create backup directory if it doesn't exist
        if ! [ -d "$BACKUP_DIR" ]; then
          log_message "INFO" "Creating backup directory $BACKUP_DIR"
          if ! ${pkgs.coreutils}/bin/mkdir -p "$BACKUP_DIR"; then
            log_message "ERROR" "Failed to create backup directory"
            return 1
          fi
        fi
        
        # Verify we can write to the backup directory
        local test_file="$BACKUP_DIR/.write_test"
        if ! touch "$test_file" 2>/dev/null; then
          log_message "ERROR" "Cannot write to backup directory"
          return 1
        fi
        rm -f "$test_file"
        
        log_message "INFO" "Mount verification successful"
        return 0
      done
      
      log_message "ERROR" "Mount verification timed out after $max_attempts attempts"
      return 1
    }

    mount_drive() {
      log_message "INFO" "Attempting to mount backup drive..."
      
      # Check if device exists
      if ! check_device; then
        return 1
      fi  # Fixed the syntax error here - removed the brace

      # Power up the drive if in standby
      local power_state=$(${pkgs.hdparm}/bin/hdparm -C "$DEVICE" 2>&1)
      log_message "INFO" "Drive power state: $power_state"
      
      if echo "$power_state" | grep -q "standby"; then
        log_message "INFO" "Powering up drive..."
        ${pkgs.hdparm}/bin/hdparm -S 0 "$DEVICE"
        sleep 5
      fi
      
      ${pkgs.coreutils}/bin/mkdir -p "$MOUNT_POINT"
      
      # Try mounting by UUID
      log_message "INFO" "Attempting to mount by UUID: $UUID"
      if ${pkgs.util-linux}/bin/mount -U "$UUID" -t ntfs3 -o uid=0,gid=0,fmask=0133,dmask=0022 "$MOUNT_POINT"; then
        if verify_mount; then
          return 0
        fi
        ${pkgs.util-linux}/bin/umount "$MOUNT_POINT" 2>/dev/null
      fi
      
      # Try mounting by LABEL
      log_message "INFO" "UUID mount failed, attempting mount by LABEL: $LABEL"
      if ${pkgs.util-linux}/bin/mount -L "$LABEL" -t ntfs3 -o uid=0,gid=0,fmask=0133,dmask=0022 "$MOUNT_POINT"; then
        if verify_mount; then
          return 0
        fi
        ${pkgs.util-linux}/bin/umount "$MOUNT_POINT" 2>/dev/null
      fi
      
      log_message "ERROR" "All mount attempts failed"
      touch /tmp/mount-failed-docker-backup-external
      return 1
    }

    unmount_drive() {
      log_message "INFO" "Attempting to unmount backup drive..."
      
      sync  # Ensure all writes are finished
      
      if ${pkgs.util-linux}/bin/umount "$MOUNT_POINT"; then
        log_message "INFO" "Drive unmounted successfully"
        log_message "INFO" "Attempting to power down drive..."
        if ${pkgs.hdparm}/bin/hdparm -y "$DEVICE"; then
          log_message "INFO" "Drive powered down successfully"
        else
          log_message "WARNING" "Failed to power down drive"
        fi
        return 0
      else
        local mount_status=$(${pkgs.util-linux}/bin/mount | grep "$MOUNT_POINT")
        log_message "ERROR" "Failed to unmount drive. Mount status: $mount_status"
        return 1
      fi
    }

    # Main execution
    if ! is_mounted; then
      mount_drive
      exit_code=$?
      if [ $exit_code -ne 0 ]; then
        log_message "ERROR" "Mount operation failed with exit code $exit_code"
        exit $exit_code
      fi
    fi
  '';
in
{
  environment.systemPackages = [ mountScript ];

systemd.services.backup-drive-mount = {
  description = "Mount backup drive for nightly operations";
  after = [ "network.target" ];
  serviceConfig = {
    Type = "oneshot";
    ExecStart = "${mountScript}/bin/mount-backup-drive";
    ExecStartPost = [
      "${pkgs.coreutils}/bin/chown root:users /mnt/external_drive"
      "${pkgs.coreutils}/bin/chmod 775 /mnt/external_drive"
      "${pkgs.shadow}/bin/usermod -a -G users dylan"
    ];
    User = "root";
    Group = "root";
  };
};

  systemd.timers.backup-drive-mount = {
    description = "Schedule backup drive mounting";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 03:00:00";
      Persistent = true;
    };
  };
}
