{settings,lib, config, pkgs, ... }:
  let cfg = settings.terminal.extras;

in
{

  imports = [
    ./btop.nix
    ./rust.nix
    ./lazygit.nix
    ./fonts.nix
    ./cava.nix
    ./ytfzf.nix
    ./aichat.nix
    ./nushell.nix
    ./atuin.nix
    ./thefuck.nix
    ./carapace.nix
  ];
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
  imagemagick
  rustscan
  ];
  };
}

