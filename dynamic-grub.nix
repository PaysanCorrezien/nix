{ config, pkgs, ... }:

{
boot.loader.systemd-boot.enable = false;

  boot.loader.grub.enable                = true;
  boot.loader.grub.copyKernels           = true;
#  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.grub.efiSupport            = true;
  boot.loader.grub.fsIdentifier          = "uuid";  
  boot.loader.grub.splashMode            = "stretch";

  boot.loader.grub.devices               = [ "nodev" ];
  boot.loader.grub.configurationLimit = 50;
  boot.loader.grub.default = "0";
  boot.loader.timeout = 10;
  

  boot.loader.efi.canTouchEfiVariables = true;

  boot.loader.grub.extraEntries = ''
    menuentry "Reboot" {
      reboot
    }
    menuentry "Poweroff" {
      halt
    }
'';
}

