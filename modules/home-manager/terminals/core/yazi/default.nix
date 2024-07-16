{ lib, pkgs, config, ... }:

let
in {

  home.packages = with pkgs; [ miller ouch xdragon zoxide ueberzugpp ];

  programs.yazi = { enable = true; };
}

