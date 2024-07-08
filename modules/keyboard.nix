# keyboard.nix
{ config, pkgs, ... }:

{
  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "fr,us";
    xkb.variant = ",altgr-intl";
    # xkb.options = "grp:alt_shift_toggle"; # Use Alt+Shift to switch between layouts
  };

  # Configure console keymap
  console.keyMap = "fr";

  environment.systemPackages = with pkgs; [
vial
qmk 
qmk_hid
keymapviz
  ];
}

