{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf (config.settings.windowManager == "hyprland") {

    environment.sessionVariables.NIXOS_OZONE_WL = "1";
    environment.sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";
    # Required packages
    environment.systemPackages = with pkgs; [
      gjs
      glib
      gobject-introspection
      ags
      bun
      gtk3
      libgtop
      # python-gpustat
      grimblast
      gpu-screen-recorder
      hyprpicker
      hyprsunset
      hypridle
      matugen
      swww
      sass
      libdbusmenu-gtk3
      networkmanager
      brightnessctl
      # bluez
      pipewire
      btop

      wofi # Application launcher
      waybar # Status bar
      wl-clipboard # Wayland clipboard utilities
      cliphist # Clipboard manager
      hyprpaper # Wallpaper
      hypridle # Idle daemon
      hyprpicker # Color picker
      swaynotificationcenter # Notification center
      grim # Screenshot utility
      slurp # Screen area selection
      pavucontrol # Audio control
      networkmanagerapplet # Network manager
      blueman # Bluetooth manager
      playerctl
      brightnessctl
      kitty
      pyprland
      hyprpicker
      # hyprcursor
      hyprlock
      hypridle
      hyprpaper
      # inputs.wezterm.packages.${pkgs.system}.default
      cool-retro-term
      starship
      zathura
      mpv
      imv
      udiskie # Automount USB drives
    ];
    services.udisks2.enable = true; # usb manager
    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true;
    services.blueman.enable = true;
    hardware.enableAllFirmware = true;
    boot.kernelParams = [
      "acpi_osi=Linux"
      "acpi_backlight=vendor"
      "acpi_enforce_resources=lax"
    ];

    services.pipewire = {
      enable = true;
    };
    services.journald = {
      storage = "persistent"; # or "volatile" if you don't need persistent logs
      # Limit journal size and retention
      extraConfig = ''
        SystemMaxUse=100M
        SystemMaxFileSize=50M
        MaxFileSec=7day
        MaxRetentionSec=1month
        Compress=yes
        # This should help with slow startups
        ForwardToConsole=no
        ForwardToWall=no
        SyncIntervalSec=5m
      '';
    };

    services.power-profiles-daemon.enable = true;
  };
}
