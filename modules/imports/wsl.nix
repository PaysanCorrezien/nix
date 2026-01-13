# WSL imports (no GUI, no bootloader, no keyboard hardware)
{ inputs, ... }:

{
  imports = [
    ./base.nix
    inputs.nixos-wsl.nixosModules.wsl
    ../system/terminal/terminal.nix
  ];

  # WSL doesn't need bootloader, monitoring, or keyboard hardware config
}
