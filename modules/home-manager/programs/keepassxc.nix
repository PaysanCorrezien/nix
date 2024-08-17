# TODO: a wrapper that fetch the secrets from keepass and export them as env vars ?
# keepass-secrets-script = pkgs.writeScriptBin "generate-keepass-secrets" ''
#   #!/usr/bin/env bash
#   set -euo pipefail
#
#   KEEPASS_DB="${keepassdb_path}"
#   SECRETS_FILE="$HOME/.config/zsh/secrets.zsh"
#
#   if [[ -f "$SECRETS_FILE" ]]; then
#     echo "Secrets file already exists. Delete it if you want to regenerate."
#     exit 0
#   fi
#
#   echo "KeePass database needs to be unlocked to generate secrets."
#   echo "Please enter your KeePass database password:"
#   read -s KEEPASS_PASSWORD
#
#   echo "Attempting to unlock KeePass database..."
#   if ! echo "$KEEPASS_PASSWORD" | ${pkgs.keepassxc}/bin/keepassxc-cli open "$KEEPASS_DB" > /dev/null 2>&1; then
#     echo "Failed to unlock KeePass database. Please try again."
#     exit 1
#   fi
#
#   echo "# Generated KeePass secrets" > "$SECRETS_FILE"
#
#   for key in ${lib.concatStringsSep " " api_keys}; do
#     echo "Retrieving $key..."
#     VALUE=$(echo "$KEEPASS_PASSWORD" | ${pkgs.keepassxc}/bin/keepassxc-cli show -a Password -s "$KEEPASS_DB" "$key")
#     echo "export $key=\"$VALUE\"" >> "$SECRETS_FILE"
#   done
#
#   echo "Secrets file generated at $SECRETS_FILE"
# '';
#
# post-activation-script = pkgs.writeShellScript "post-activation-script" ''
#   if [[ ! -f "$HOME/.config/zsh/secrets.zsh" ]]; then
#     echo "Secrets file does not exist. Running generation script..."
#     ${keepass-secrets-script}/bin/generate-keepass-secrets
#   else
#     echo "Secrets file already exists. Skipping generation."
#   fi
# '';
#   home.activation = {
#   generateKeepassSecrets = lib.hm.dag.entryAfter ["writeBoundary"] ''
#     $DRY_RUN_CMD ${pkgs.bash}/bin/bash ${post-activation-script}
#   '';
# };
# api_keys = [
#   "GH_TOKEN"
#   "OPENAI_API_KEY"
#   "TODOIST_API_TOKEN"
#   "BROWSERLESS_API_KEY"
#   # Add more API keys as needed
# ];

{ config, pkgs, lib, ... }:

let
  keepassdb_path =
    "${config.home.homeDirectory}/Documents/Password/DylanMDP.kdbx";
  keepassxcConfig = {
    "General" = {
      "StartMinimized" = "false";
      "MinimizeToTray" = "true";
      "ShowTrayIcon" = "true";
      "MinimizeOnStartup" = "false";
      "SaveDatabase" = "true";
      "RememberLastDatabases" = "true";
      "AutoSaveAfterEveryChange" = "true";
    };
    "GUI" = { "ApplicationTheme" = "dark"; };
    "Security" = {
      "UseBrowserIntegration" = "true";
      "UseKeyFile" = "false";
      "QuickUnlock" = "true";
      "QuickUnlockTimeout" = "0";
      "ClearClipboardAfterSeconds" = "30";
      "ClearClipboardTimeout" = "30";
      "LockDatabaseMinimize " = "false";
      "LockDatabaseScreenLock " = "false";
      "RelockAutoType " = "false";
    };
    "SSHAgent" = {
      "Enabled" = "true";
      "EnableSSHAgent" = "true";
      "UseOpenSSH" = "true";
    };
    "Browser" = {
      "EnableBrowserIntegration" = "true";
      "Enabled" = " true";
      "AllowedBrowsers" = "firefox";
    };
    "Database" = {
      "DefaultDatabasePath" = "${keepassdb_path}";
      "AutoOpenDatabases" = "true";
    };
  };

  customToINI = lib.generators.toINI {
    mkKeyValue = lib.generators.mkKeyValueDefault {
      mkValueString = v:
        if lib.isBool v then
          (if v then "true" else "false")
        else if lib.isString v then
          v
        else
          lib.generators.mkValueStringDefault { } v;
    } "=";
  };

in {
  options = {
    settings = lib.mkOption {
      type = lib.types.submodule {
        options.keepassxc = lib.mkOption {
          type = lib.types.submodule {
            options.enable =
              lib.mkEnableOption "Enable custom KeePass configuration";
          };
        };
      };
    };
  };

  config = lib.mkIf config.settings.keepassxc.enable {
    home.packages = with pkgs; [ keepassxc keepmenu pinentry-gtk2 ];

    home.activation.copyKeepassxcConfig =
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            if [ ! -f ${config.home.homeDirectory}/.config/keepassxc/keepassxc.ini ]; then
              mkdir -p ${config.home.homeDirectory}/.config/keepassxc
              cat << EOF > ${config.home.homeDirectory}/.config/keepassxc/keepassxc.ini
        ${customToINI keepassxcConfig}
        EOF
              chmod 600 ${config.home.homeDirectory}/.config/keepassxc/keepassxc.ini
            fi
      '';
  };
}
