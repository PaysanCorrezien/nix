{ config, pkgs, lib, ... }:

let
  keepassxcConfig = {
    "General" = {
      "StartMinimized" = "false";                       # Do not start KeePassXC minimized
      "MinimizeToTray" = "true";                        # Minimize to system tray instead of closing
      "ShowTrayIcon" = "true";                          # Always show the tray icon
      "MinimizeOnStartup" = "false";                    # Do not minimize on startup
      "SaveDatabase" = "true";                          # Automatically save the database
      "RememberLastDatabases" = "true";                 # Remember the last opened databases
      "AutoSaveAfterEveryChange" = "true";              # Auto save database after every change
    };
    "GUI" = {
      "ApplicationTheme" = "dark";                      # Use dark color scheme
    };
    "Security" = {
      "UseBrowserIntegration" = "true";                 # Enable browser integration
      "UseKeyFile" = "false";                           # Do not use a key file
      "QuickUnlock" = "true";                           # Enable quick unlock feature
      "QuickUnlockTimeout" = "0";                       # No timeout for quick unlock
      "ClearClipboardAfterSeconds" = "30";              # Clear clipboard after 30 seconds
    };
    "SSHAgent" = {
      "Enabled" = "true";
      "EnableSSHAgent" = "true";                        # Enable SSH agent integration
      "UseOpenSSH" = "true";
    };
    "Browser" = {
      "EnableBrowserIntegration" = "true";              # Enable browser integration
    };
    "Database" = {
      "DefaultDatabasePath" = "/home/user/Documents/Password/password.kdbx";  # Set default database path
      "AutoOpenDatabases" = "true";                     # Automatically open last used databases
    };
  };

  customToINI = lib.generators.toINI {
    mkKeyValue = lib.generators.mkKeyValueDefault {
      mkValueString = v:
        if lib.isBool v then (if v then "true" else "false")
        else if lib.isString v then v
        else lib.generators.mkValueStringDefault {} v;
    } "=";
  };
 

in
{
  # Enable KeePassXC
  home.packages = with pkgs; [
    keepassxc
  ];

  # Set up KeePassXC configuration
  home.file.".config/keepassxc/keepassxc.ini".text = customToINI keepassxcConfig;

  # # Start KeePassXC on boot
  # systemd.user.services.keepassxc = {
  #   description = "KeePassXC Password Manager";
  #   serviceConfig = {
  #     ExecStart = "${pkgs.keepassxc}/bin/keepassxc";
  #     Restart = "always";
  #     RestartSec = 5;
  #   };
  #   wantedBy = [ "default.target" ];
  # };
}

