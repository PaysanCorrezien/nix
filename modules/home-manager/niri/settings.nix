{
  lib,
  settings,
  ...
}:
{
  config = lib.mkIf (settings.windowManager == "niri") {
    home.file.".config/niri/config.kdl".source = ./config.kdl;
  };
}
