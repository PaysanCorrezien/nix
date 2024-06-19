#!/bin/sh
#TODO: enable service automatically

# URL to your chezmoi dotfiles repository
REPO_URL="https://github.com/PaysanCorrezien/dotfiles"

# Function to send notifications
send_notification() {
  if command -v notify-send &> /dev/null; then
    notify-send "$1" "$2"
  else
    echo "Notification: $1 - $2"
  fi
}

# Check if chezmoi is already set up
if [ -d "$HOME/.config/chezmoi" ]; then
  send_notification "chezmoi Setup" "chezmoi is already set up. Applying changes..."
  echo "chezmoi is already set up. Applying changes..."

  chezmoi update
else
  send_notification "chezmoi Setup" "chezmoi is not set up. Initializing from $REPO_URL..."
  echo "chezmoi is not set up. Initializing from $REPO_URL..."

  # Ensure the directory exists
  mkdir -p "$HOME/.config/chezmoi"

  cat <<EOF > ~/.config/chezmoi/chezmoi.toml
[data]
  git = { name="toto", email="toto@mail.com", gpg="agpgkey" }
  windowsUsername = "toto"
EOF

  chezmoi init --apply $REPO_URL
  send_notification "chezmoi Setup" "chezmoi is now set from $REPO_URL... DONT FORGET TO replace template values by real ones"
  
systemctl --user daemon-reload
systemctl --user enable chezmoi-setup.service
systemctl --user start chezmoi-setup.service
fi

# Reload the systemd user daemon and enable the chezmoi-setup service

