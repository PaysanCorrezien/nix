#!/usr/bin/env bash

# Prompt for comment
read -p "Enter comment for key (e.g., email or user@host): " comment

# Prompt for key name/location
read -p "Enter key name (default: id_ed25519): " keyname
keyname=${keyname:-id_ed25519}

# Generate key with increased KDF rounds
ssh-keygen -t ed25519 -a 100 -C "$comment" -f "$HOME/.ssh/$keyname"

# Show the public key
echo -e "\nYour public key:"
cat "$HOME/.ssh/$keyname.pub"

# Set correct permissions
chmod 600 "$HOME/.ssh/$keyname"
chmod 644 "$HOME/.ssh/$keyname.pub"

echo -e "\nKey pair generated:"
echo "Private key: $HOME/.ssh/$keyname"
echo "Public key:  $HOME/.ssh/$keyname.pub"
