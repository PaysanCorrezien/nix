{ pkgs, lib, settings, ... }:
let cfg = settings.terminal.extras;
in { config = lib.mkIf cfg.enable { programs.lazygit.enable = true; }; }
