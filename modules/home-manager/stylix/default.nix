{
  lib,
  config,
  settings,
  ...
}:
let
  # Check if stylix is enabled by checking if the window manager is not niri
  # This mirrors the NixOS-level logic
  stylixEnabled = (settings.windowManager or null) != "niri" && (settings.windowManager or null) != null && !(settings.isServer or false);
in
{
  config = lib.mkIf stylixEnabled {
    stylix = {
      targets = {
        neovim.enable = false;
        rofi.enable = false;
      };
    };
  };
}
