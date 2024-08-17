{ config, pkgs, ... }:

{
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
    efiSysMountPoint = "/boot";
  };
  boot.kernelParams = [ "root=/dev/disk/by-partlabel/disk-main-root" ];
}

# boot.loader.grub.copyKernels = true;
#  boot.loader.grub.efiInstallAsRemovable = true;
# boot.loader.grub.fsIdentifier = "uuid";
# boot.loader.grub.splashMode = "stretch";

# boot.loader.grub.configurationLimit = 50;
# boot.loader.grub.default = "0";
# boot.loader.timeout = 10;

