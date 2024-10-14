{ config, pkgs, lib, ... }:

# TODO: Enable firefox as allowed Browser
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
#FIX: this doenst work ? where is this set ?
      "AllowedBrowsers" = "firefox";
    };
    "Database" = {
      "DefaultDatabasePath" = "${keepassdb_path}";
      "AutoOpenDatabases" = "true";
    };
  };

  customToINI = lib.generators.toINI {
    mkKeyValue = lib.generators.mkKeyValueDefault
      {
        mkValueString = v:
          if lib.isBool v then
            (if v then "true" else "false")
          else if lib.isString v then
            v
          else
            lib.generators.mkValueStringDefault { } v;
      } "=";
  };

in
{
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
    home.packages = with pkgs; [ keepassxc keepmenu pinentry-gtk2 bitwarden-cli bitwarden-desktop];

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
