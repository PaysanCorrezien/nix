{ config, pkgs, lib, ... }:

let
  cfg = config.settings.disko;
in
{
  config = let
    efiMountPoint = if cfg.layout == "standard" then "/boot" else "/boot/efi";
  in {
    boot.loader.systemd-boot.enable = false;
    boot.loader.grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
      forceInstall = true;
      efiInstallAsRemovable = true;
      useOSProber = false;
      extraEntries = ''
        menuentry "Reboot" {
          reboot
        }
        menuentry "Poweroff" {
          halt
        }
      '';
    };
    boot.loader.efi = {
      # canTouchEfiVariables = true;
      efiSysMountPoint = efiMountPoint;
    };
    boot.kernelParams = [ "root=/dev/disk/by-partlabel/disk-main-root" ];
  };
}

# boot.loader.grub.copyKernels = true;
#  boot.loader.grub.efiInstallAsRemovable = true;
# boot.loader.grub.fsIdentifier = "uuid";
# boot.loader.grub.splashMode = "stretch";

# boot.loader.grub.configurationLimit = 50;
# boot.loader.grub.default = "0";
# boot.loader.timeout = 10;

