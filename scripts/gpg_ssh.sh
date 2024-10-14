echo "Setting up GPG and SSH keys from Bitwarden..."

# Create ~/repo if it doesn't exist
mkdir -p ~/repo

# Clone the repository if it doesn't exist
if [ ! -d "~/repo/bitwarden-cli-retriever" ]; then
	echo "Cloning the bitwarden-cli-retriever repository..."
	cd ~/repo
	git clone https://github.com/PaysanCorrezien/bitwarden-cli-retriever
fi

cd ~/repo/bitwarden-cli-retriever

# Function to prompt for .env values
prompt_env_value() {
	local var_name="$1"
	local default_value="$2"
	local prompt_text="$3"

	read -p "$prompt_text [$default_value]: " value
	value=${value:-$default_value}
	echo "$var_name=\"$value\"" >>.env
}

# Generate .env file
echo "Generating .env file..."
rm -f .env # Remove existing .env file if it exists
prompt_env_value "BW_URL" "https://vault.bitwarden.com" "Enter your Bitwarden URL"
prompt_env_value "BW_EMAIL" "" "Enter your Bitwarden email"
#TODO: make this prompt without showing pass maybe ?
prompt_env_value "BW_PASSWORD" "" "Enter your Bitwarden master password"

# Function to run bitwarden-cli-retriever.sh
run_bitwarden_cli() {
	local key_type="$1"
	local output_file="$2"
	echo "Retrieving $key_type key..."
	script -qec "./bitwarden-cli-retriever.sh --config .env $key_type > $output_file" /dev/null
}

# Retrieve GPG key
run_bitwarden_cli GPG_KEY ~/.ssh/GIT_GPG_private.asc

# Retrieve SSH key
run_bitwarden_cli GIT_SSH ~/.ssh/GIT_ssh_priv

# Retrieve CHEZMOI_TOML
run_bitwarden_cli CHEZMOI_TOML ~/.config/chezmoi/chezmoi.toml

# Set proper permissions for SSH key
chmod 600 ~/.ssh/GIT_ssh_priv

# Import GPG key
echo "Importing GPG key..."
gpg --import ~/.ssh/GIT_GPG_private.asc

# Get the GPG key ID
GPG_KEY_ID=$(gpg --list-secret-keys --keyid-format LONG | grep sec | cut -d'/' -f2 | cut -d' ' -f1)

# Add GPG key to the agent
echo "Adding GPG key to the agent. You may be prompted for your passphrase."
gpg-connect-agent reloadagent /bye

# Add SSH key to the agent
echo "Adding SSH key to the agent. You may be prompted for your passphrase."
ssh-add ~/.ssh/GIT_ssh_priv

echo "Setup complete!"
echo "GPG Key ID: $GPG_KEY_ID"
echo "SSH Key: ~/.ssh/GIT_ssh_priv"
