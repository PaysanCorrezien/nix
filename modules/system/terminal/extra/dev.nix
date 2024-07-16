{ config, pkgs, lib, ... }:

let cfg = config.settings.terminal.extras;
in {
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      nil # LSP for nix
      haskellPackages.nixfmt
      # nodejs_21
      gitleaks
      zig
      ffmpeg
      pyenv
    ];
  };
}
