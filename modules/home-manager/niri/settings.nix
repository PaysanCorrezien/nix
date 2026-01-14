{
  lib,
  settings,
  ...
}:
{
  config = lib.mkIf (settings.windowManager == "niri") {
    settings.gnome.extra.enable = lib.mkForce false;
    settings.hyprland.extra.enable = lib.mkForce false;
    home.file.".config/niri/config.kdl".source = ./config.kdl;
  };
}
