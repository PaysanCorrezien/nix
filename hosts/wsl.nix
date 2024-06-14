# hosts/WSL.nix
{ config, pkgs, ... }:

{
  networking.hostName = "WSL";
  
# dynamic grub need to work this
  boot.loader.grub.device = "nodev"; # Adjust as needed for WSL

  # Host-specific configurations
  # Since WSL might not have a traditional desktop environment, you can skip DE settings or add specific WSL-related settings
  services.xserver.displayManager.lightdm.enable = false;
  services.xserver.desktopManager.gnome.enable = false;

  # Other host-specific settings

}

