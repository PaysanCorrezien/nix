{ config, pkgs, ... }:

{
  imports = [
    ./btop.nix
    ./rust.nix
    ./lazygit.nix
    ./fonts.nix
    ./cava.nix
    ./ytfzf.nix
    ./aichat.nix
    ./atuin.nix
  ];
}

