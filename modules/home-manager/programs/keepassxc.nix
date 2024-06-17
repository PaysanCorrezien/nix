# keepassxc.nix

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
      "ColorScheme" = "dark";                           # Use dark color scheme
      "UnlockDatabase" = "true";                        # Unlock database on startup
    };
    "Security" = {
      "UseBrowserIntegration" = "true";                 # Enable browser integration
      "UseKeyFile" = "false";                           # Do not use a key file
      "QuickUnlock" = "true";                           # Enable quick unlock feature
      "QuickUnlockTimeout" = "0";                       # No timeout for quick unlock
      "ClearClipboardAfterSeconds" = "30";              # Clear clipboard after 30 seconds
    };
    "SSHAgent" = {
      "EnableSSHAgent" = "true";                        # Enable SSH agent integration
    };
    "Browser" = {
      "EnableBrowserIntegration" = "true";              # Enable browser integration
    };
    "Database" = {
## FIXME: adjust this
      "DefaultDatabasePath" = "${pkgs.lib.getHomeDir}/Documents/Password/password.kdbx";  # Set default database path
      "AutoOpenDatabases" = "true";                     # Automatically open last used databases
    };
  };
in
{
  # Enable KeePassXC
  environment.systemPackages = with pkgs; [
    keepassxc
  ];

  # Set up KeePassXC configuration
  environment.etc."xdg/keepassxc/keepassxc.ini".text = pkgs.lib.generators.toINI keepassxcConfig;

# NOTE: check if realy needed or window manager handle this
  # Start KeePassXC on boot
  systemd.user.services.keepassxc = {
    description = "KeePassXC Password Manager";
    serviceConfig = {
      ExecStart = "${pkgs.keepassxc}/bin/keepassxc";
      Restart = "always";
      RestartSec = 5;
    };
    wantedBy = [ "default.target" ];
  };
}

