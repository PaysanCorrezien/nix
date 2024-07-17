{ config, pkgs, ... }:

{
  imports = [ ./btop.nix ./rust.nix ./lazygit.nix ./fonts.nix ];
}

