set -e

# Prepare installation environment
# mkdir -p /mnt/etc/nixos

# Generate hardware configuration
# nixos-generate-config --root /mnt

# Move hardware configuration to the expected location
# mv /mnt/etc/nixos/hardware-configuration.nix /mnt/etc/nixos/

# sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko --flake github:paysancorrezien/nix#default --no-write-lock-file
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko --flake github:paysancorrezien/nix#diskoConfigurations.default --no-write-lock-file

# sudo nixos-install --flake github:paysancorrezien/nix#lenovo --no-write-lock-file
# nixos-install --flake github:paysancorrezien/nix#lenovo --no-write-lockfile --show-trace

echo "Installation complete. Please reboot into your new system."
