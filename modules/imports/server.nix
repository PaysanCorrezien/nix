# Server imports (no GUI, no keyboard hardware, bootloader enabled)
{ inputs, ... }:

{
  imports = [
    ./base.nix
    ../system/terminal/terminal.nix
    ../monitoring/default.nix
    ../../dynamic-grub.nix
  ];
}
