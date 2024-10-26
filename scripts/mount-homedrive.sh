#!/usr/bin/env bash
# Auto USB Drive Mount/Unmount Script
# This script automatically detects if the drive is mounted and performs the appropriate action.

# Hardcoded values
DEVICE="/dev/sdc"
UUID="54206E3D206E2668"
LABEL="SAMSUNG"
MOUNT_POINT="/mnt/external_drive"
LOG_FILE="/var/log/usb_drive_operations.log"

# Function to log messages
log_message() {
	echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | sudo tee -a "$LOG_FILE"
}

# Function to check if the drive is mounted
is_mounted() {
	mountpoint -q "$MOUNT_POINT"
}

# Function to mount the drive
mount_drive() {
	log_message "Attempting to mount drive..."

	# Power up the drive
	if sudo hdparm -C "$DEVICE" | grep -q "standby"; then
		log_message "Powering up drive..."
		sudo hdparm -S 0 "$DEVICE"
	fi

	# Create mount point if it doesn't exist
	sudo mkdir -p "$MOUNT_POINT"

	# Attempt to mount by UUID
	if sudo mount -U "$UUID" "$MOUNT_POINT"; then
		log_message "Drive mounted successfully at $MOUNT_POINT"
	else
		log_message "Failed to mount by UUID. Attempting to mount by LABEL..."
		if sudo mount -L "$LABEL" "$MOUNT_POINT"; then
			log_message "Drive mounted successfully at $MOUNT_POINT"
		else
			log_message "Failed to mount drive. Please check the device."
			return 1
		fi
	fi
}

# Function to unmount the drive
unmount_drive() {
	log_message "Attempting to unmount drive..."

	if sudo umount "$MOUNT_POINT"; then
		log_message "Drive unmounted successfully"

		# Power down the drive
		log_message "Powering down drive..."
		sudo hdparm -y "$DEVICE"

		log_message "Drive operation completed successfully"
	else
		log_message "Failed to unmount drive. It might be in use."
		return 1
	fi
}

# Main script logic
if is_mounted; then
	log_message "Drive is currently mounted. Proceeding to unmount."
	unmount_drive
else
	log_message "Drive is not mounted. Proceeding to mount."
	mount_drive
fi
