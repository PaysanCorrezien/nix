{ config, pkgs, lib, ... }:
let
  thunderbirdSecretsPath = "/run/secrets";

  # Function to read a secret file and return its content or an empty string
  readSecretFile = name: 
    let 
      path = "${thunderbirdSecretsPath}/${name}";
    in 
      if builtins.pathExists path then builtins.readFile path else "";

  account1 = {
    name = readSecretFile "thunderbird/account1/name";
    email = readSecretFile "thunderbird/account1/email";
    server = readSecretFile "thunderbird/account1/server";
    port = readSecretFile "thunderbird/account1/port";
    username = readSecretFile "thunderbird/account1/username";
  };

  account2 = {
    name = readSecretFile "thunderbird/account2/name";
    email = readSecretFile "thunderbird/account2/email";
    server = readSecretFile "thunderbird/account2/server";
    port = readSecretFile "thunderbird/account2/port";
    username = readSecretFile "thunderbird/account2/username";
  };

in
{
  programs.thunderbird = {
    enable = true;
  };

  # This activation script sets up Thunderbird from scratch
  system.activationScripts.thunderbird-setup = lib.stringAfter [ "users" ] ''
    THUNDERBIRD_CONFIG_DIR="/home/dylan/.thunderbird"
    PROFILE_NAME="nix-profile"
    PROFILE_DIR="$THUNDERBIRD_CONFIG_DIR/$PROFILE_NAME"

    NAME="${account1.name}"
    EMAIL="${account1.email}"
    SERVER="${account1.server}"
    PORT="${account1.port}"
    USERNAME="${account1.username}"

    NAME2="${account2.name}"
    EMAIL2="${account2.email}"
    SERVER2="${account2.server}"
    PORT2="${account2.port}"
    USERNAME2="${account2.username}"

    # Create Thunderbird configuration directory if it doesn't exist
    if [ ! -d "$THUNDERBIRD_CONFIG_DIR" ]; then
      mkdir -p "$THUNDERBIRD_CONFIG_DIR"
      
      # Create profiles.ini
      cat << EOF > "$THUNDERBIRD_CONFIG_DIR/profiles.ini"
[General]
StartWithLastProfile=1

[Profile0]
Name=$PROFILE_NAME
IsRelative=1
Path=$PROFILE_NAME
Default=1
EOF

      # Create the profile directory
      mkdir -p "$PROFILE_DIR"

      # Create prefs.js with both accounts
      cat << EOF > "$PROFILE_DIR/prefs.js"
// Account1
user_pref("mail.accountmanager.accounts", "account1,account2");
user_pref("mail.account.account1.identities", "id1");
user_pref("mail.account.account1.server", "server1");
user_pref("mail.identity.id1.fullName", "$NAME");
user_pref("mail.identity.id1.useremail", "$EMAIL");
user_pref("mail.server.server1.hostname", "$SERVER");
user_pref("mail.server.server1.port", $PORT);
user_pref("mail.server.server1.username", "$USERNAME");
user_pref("mail.server.server1.type", "imap");
user_pref("mail.server.server1.socketType", 3);


// Account2
user_pref("mail.account.account2.identities", "id2");
user_pref("mail.account.account2.server", "server2");
user_pref("mail.identity.id2.fullName", "$NAME2");
user_pref("mail.identity.id2.useremail", "$EMAIL2");
user_pref("mail.server.server2.hostname", "$SERVER2");
user_pref("mail.server.server2.port", $PORT2);
user_pref("mail.server.server2.username", "$USERNAME2");
user_pref("mail.server.server2.type", "imap");
user_pref("mail.server.server2.socketType", 3);


// prefs and others settings
user_pref("calendar.timezone.local", "Europe/Paris");
user_pref("browser.search.region", "FR");
user_pref("spellchecker.dictionary", "en-US,fr");





EOF

      # Ensure correct permissions
      chown -R dylan:users "$THUNDERBIRD_CONFIG_DIR"
      chmod 700 "$THUNDERBIRD_CONFIG_DIR"
      chmod 600 "$PROFILE_DIR/prefs.js"
    fi
  '';
}

