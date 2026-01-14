{
  config,
  lib,
  pkgs,
  ...
}:

# Ultra-minimal VMware host for bootstrap install
# After install, switch to vmware: nixos-rebuild switch --flake .#vmware

{
  config.settings = {
    isServer = true;
    hostname = "vmware-minimal";
    username = "dylan";
    architecture = "x86_64";
    virtualisation.enable = true;
    disko.mainDisk = "/dev/sda";
    disko.layout = "standard";
    environment = "home";
    gaming = false;
    social.enable = false;
    locale = "fr_FR.UTF-8";
    autoSudo = true;
    yubikey.enable = false;
    ssh.enable = false;
    tailscale.enable = false;
    windowManager = null;
    displayServer = null;
  };

  config.users.users.${config.settings.username} = {
    initialHashedPassword = "$6$.NL5Jii4wwztUzFC$pOiZJ3I2810HLcCZc0CYR5YGEHS6JWibJ75mbx4TWcm0gsxuEAsSK4rsDxu1Ny7o67..V4hdX3mwJQ4enHCJ6.";
    group = "dylan";
    home = "/home/${config.settings.username}";
  };
  config.users.groups.dylan = { };

  config.virtualisation.vmware.guest.enable = true;

  config.networking = {
    hostName = config.settings.hostname;
    networkmanager.enable = true;
  };
}
