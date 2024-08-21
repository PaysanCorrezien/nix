{ config, pkgs, lib, ... }:

let
  # Trace the entire config.settings set for debugging
  debugSettings = builtins.trace
    "keyboard.nix: config.settings = ${builtins.toJSON config.settings}"
    config.settings;
in
{
  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "us,fr";
    xkb.variant = "altgr-intl,";
  };

  # Configure console keymap
  console.keyMap = "us";

  # Conditionally include packages based on the `isServer` variable
  environment.systemPackages = with pkgs;
    (if debugSettings.isServer then [ ] else [ vial qmk qmk_hid keymapviz ]);

  # Add udev rule for Vial device
  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
  '';
}
