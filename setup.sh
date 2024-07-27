set -e

# Prepare installation environment
mkdir -p /mnt/etc/nixos

# Generate hardware configuration
nixos-generate-config --root /mnt

# Move hardware configuration to the expected location
mv /mnt/etc/nixos/hardware-configuration.nix /mnt/etc/nixos/

# Install NixOS using the flake
nixos-install --flake github:paysancorrezien/nix#lenovo

echo "Installation complete. Please reboot into your new system."
