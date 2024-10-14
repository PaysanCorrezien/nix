{ lib, config, pkgs, ... }:

{
  imports = [
    ./tailscale.nix
    ./ssh.nix
  ];
    networking.hostName = config.settings.hostname;

}
