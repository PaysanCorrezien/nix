{ config, pkgs, ... }:

{
  # Enable XScreenSaver
  services.xserver.enable = true;
  services.xserver.displayManager.sessionCommands = ''
    ${pkgs.xscreensaver}/bin/xscreensaver -no-splash &
  '';

  # Install XScreenSaver
  environment.systemPackages = with pkgs; [ xscreensaver ];

  # Create a systemd service to lock the screen after resume
  systemd.services.lock-after-suspend = {
    description = "Lock screen with XScreenSaver after resume";
    wantedBy = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
    after = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
    serviceConfig = {
      Type = "simple";
      User = "1000"; # Replace with your user ID or use a variable
      Environment = "DISPLAY=:0";
      ExecStart = "${pkgs.xscreensaver}/bin/xscreensaver-command -lock";
    };
  };

}
