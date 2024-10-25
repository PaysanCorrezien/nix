{ lib, config, pkgs, ... }:

{
  imports = [
    ./tailscale.nix
    ./ssh.nix
    ./rdp.nix
  ];
    networking.hostName = config.settings.hostname;

}
