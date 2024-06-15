#!/bin/sh

# Ensure the setup script is executable and run it
chmod +x setup-disk.sh
./setup-disk.sh

# Clone your nix repo to /mnt/tmp
nix-shell -p git --run "git clone https://github.com/PaysanCorrezien/nix /mnt/tmp/nix"

# Run Disko to partition, format, and mount the disks
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko /mnt/tmp/nix/disko-config.nix

# Prepare the NixOS installation environment
mkdir -p /mnt/home/dylan/.config/nix
cp /mnt/tmp/nix/flake.nix /mnt/home/dylan/.config/nix/flake.nix

# Run the NixOS installation using the flake configuration
sudo nixos-install --flake /mnt/home/dylan/.config/nix#default --no-root-passwd

# Reboot the system
reboot
