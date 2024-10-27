{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf (config.settings.windowManager == "hyprland") {
    # programs.hyprland = {
    #   enable = true;
    #   xwayland.enable = true;
    # };
    #
    # Required packages
    environment.systemPackages = with pkgs; [
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
    ];

  };
}
