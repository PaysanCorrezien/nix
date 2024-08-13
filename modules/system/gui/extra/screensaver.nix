{ config, pkgs, ... }:

let
  lockScript = pkgs.writeShellScript "lock-screen" ''
    ${pkgs.xscreensaver}/bin/xscreensaver-command -lock
  '';
in {
  # Install XScreenSaver
  environment.systemPackages = with pkgs; [ xscreensaver ];

  # Start XScreenSaver for each user session
  systemd.user.services.xscreensaver = {
    description = "XScreenSaver";
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.xscreensaver}/bin/xscreensaver -no-splash";
      Restart = "on-failure";
    };
  };

  # Create a user service to lock the screen before sleep
  systemd.user.services.lock-on-sleep = {
    description = "Lock screen before sleep";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${lockScript}";
    };
  };

  # Create a system service to trigger the user service before sleep
  systemd.services.trigger-lock-on-sleep = {
    description = "Trigger user lock screen before sleep";
    wantedBy = [ "sleep.target" ];
    before = [ "sleep.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart =
        "${pkgs.systemd}/bin/systemctl --user --machine=1000@ start lock-on-sleep.service";
    };
  };

  # Ensure the lock service runs before sleep
  systemd.targets.sleep.unitConfig.RefuseManualStart = false;

  # Optional: Configure XScreenSaver settings
  environment.etc."xscreensaver/config".text = ''
    # ... (keep the same XScreenSaver settings as before)
  '';
}
