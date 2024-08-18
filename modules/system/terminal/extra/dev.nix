{ config, pkgs, lib, ... }:

let cfg = config.settings.terminal.extras;
in {
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # haskellPackages.nixfmt
      gitleaks
      zig
      ffmpeg
      pyenv
    ];
  };
}
