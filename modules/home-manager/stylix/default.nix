{
  lib,
  settings,
  ...
}:
let
  # Check if stylix is enabled by checking if the window manager is not niri
  stylixEnabled = (settings.windowManager or null) != "niri" && (settings.windowManager or null) != null && !(settings.isServer or false);
in
# When stylix is not enabled, return empty module to avoid referencing non-existent options
if stylixEnabled then {
  config.stylix.targets = {
    neovim.enable = false;
    rofi.enable = false;
  };
} else {
  # Empty module - no config
}
