{ config, lib, pkgs, inputs, ... }:
let cfg = config.settings.isServer;
in
{
  # imports = [ inputs.keybswitch.nixosModules.default ];
  # 
  # config = lib.mkIf (!cfg) {
  #
  # services.keybswitch = { enable = true; };
  # };

}


