{ config, pkgs, ... }:

{
  imports = [ ./btop.nix ./rust.nix ./gitui.nix ./fonts.nix ];
}

