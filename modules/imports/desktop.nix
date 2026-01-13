# Desktop/laptop imports (GUI, keyboard, full terminal tools)
{ inputs, ... }:

{
  imports = [
    ./base.nix
    inputs.stylix.nixosModules.stylix
    ../system/gui/gui.nix
    ../system/terminal/terminal.nix
    ../keyboard.nix
    ../monitoring/default.nix
    ../../dynamic-grub.nix
  ];
}
