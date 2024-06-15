#!/bin/sh

# Function to detect disks and handle user interaction
detect_disk() {
  disks=$(lsblk -d -o NAME,TYPE | grep -E 'disk' | awk '{print $1}')
  disk_count=$(echo "$disks" | wc -l)

  if [ "$disk_count" -eq 1 ]; then
    # Only one disk foun, no need for user interaction
    selected_disk=$(echo "$disks" | head -n 1)
  else
    # Multiple disks found, prompt the user to select one
    echo "Multiple disks detected. Please select a disk to use:"
    PS3="Please enter your choice: "
    select disk in $disks; do
      if [ -n "$disk" ]; then
        selected_disk=$disk
        break
      else
        echo "Invalid choice. Please try again."
      fi
    done
  fi

  # Write the selected disk to a file
  echo "/dev/$selected_disk" > /tmp/selected_disk
  echo "Selected disk: /dev/$selected_disk"
}

# Run the disk detection function
detect_disk

