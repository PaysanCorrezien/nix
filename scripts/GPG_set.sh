# Define variables
KEEPASS_DB_PATH="$HOME/Documents/Password/DylanMDP.kdbx"
KEEPASS_ENTRY_PATH="GIT_GPG_KEY"
PRIVATE_KEY_PATH="/tmp/privatekey.asc"
PUBLIC_KEY_PATH="/tmp/publickey.asc"
PRIVATE_KEY_NAME="private.asc"
PUBLIC_KEY_NAME="public.asc"

# Retrieve private key from KeePass
keepassxc-cli attachment-export "$KEEPASS_DB_PATH" "$KEEPASS_ENTRY_PATH" "$PRIVATE_KEY_NAME" "$PRIVATE_KEY_PATH"
if [[ $? -ne 0 ]]; then
	echo "Failed to retrieve private key from KeePass"
	exit 1
fi

# Retrieve public key from KeePass
keepassxc-cli attachment-export "$KEEPASS_DB_PATH" "$KEEPASS_ENTRY_PATH" "$PUBLIC_KEY_NAME" "$PUBLIC_KEY_PATH"
if [[ $? -ne 0 ]]; then
	echo "Failed to retrieve public key from KeePass"
	exit 1
fi

# Import private key into GPG
gpg --import $PRIVATE_KEY_PATH
if [[ $? -ne 0 ]]; then
	echo "Failed to import private key into GPG"
	exit 1
fi

# Import public key into GPG
gpg --import $PUBLIC_KEY_PATH
if [[ $? -ne 0 ]]; then
	echo "Failed to import public key into GPG"
	exit 1
fi

# Clean up
rm $PRIVATE_KEY_PATH
rm $PUBLIC_KEY_PATH

# List the imported keys to verify
gpg --list-secret-keys --keyid-format LONG
gpg --list-keys --keyid-format LONG

echo "GPG keys imported successfully."
