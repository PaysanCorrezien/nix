{ config, pkgs, ... }:

{
  boot.loader.systemd-boot.enable = false;

  boot.loader.grub.enable = true;
  boot.loader.grub.copyKernels = true;
  #  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.fsIdentifier = "uuid";
  boot.loader.grub.splashMode = "stretch";

  boot.loader.grub.devices = [ "nodev" ];
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
  # menuentry "NixOS - Home" {
  #   linux /boot/nixos-kernel init=/nix/store/YOUR-SYSTEM-PATH/init systemConfig=/nix/store/YOUR-SYSTEM-PATH selectedEnv=home
  #   initrd /boot/nixos-initrd
  # }
  # menuentry "NixOS - Work" {
  #   linux /boot/nixos-kernel init=/nix/store/YOUR-SYSTEM-PATH/init systemConfig=/nix/store/YOUR-SYSTEM-PATH selectedEnv=work
  #   initrd /boot/nixos-initrd
  # }
  # boot.kernelParams = [ "selectedEnv=${selectedEnv}" ];
}

