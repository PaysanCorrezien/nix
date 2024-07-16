{ config, pkgs, lib, ... }:

let
  # Trace the entire config.settings set for debugging
  debugSettings = builtins.trace
    "keyboard.nix: config.settings = ${builtins.toJSON config.settings}"
    config.settings;
in {
  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "fr,us";
    xkb.variant = ",altgr-intl";
  };

  # Configure console keymap
  console.keyMap = "fr";

  # Conditionally include packages based on the `isServer` variable
  environment.systemPackages = with pkgs;
    (if debugSettings.isServer then [ ] else [ vial qmk qmk_hid keymapviz ]);
}

