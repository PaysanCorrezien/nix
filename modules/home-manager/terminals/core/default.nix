{ config, pkgs, ... }:

{
  imports = [ ./bat.nix ./yazi/default.nix ./ripgrep.nix ];
}

