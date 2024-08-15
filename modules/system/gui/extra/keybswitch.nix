{ config, lib, pkgs, inputs, ... }:

{
  imports = [ inputs.keybswitch.nixosModules.default ];

  services.keybswitch = { enable = true; };

}

