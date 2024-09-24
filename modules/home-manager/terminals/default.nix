{ config, pkgs, ... }:

{
  imports = [
    ./core/default.nix
    ./extras/default.nix
  ];
}

