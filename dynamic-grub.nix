# grub.nix
{ config, lib, ... }:
let
  cfg = config.settings.disko;
  efiMountPoint = if cfg.layout == "standard" then "/boot" else "/boot/efi";
  isWSL = config.wsl.enable or false;
in
{
  config = lib.mkMerge [
    (lib.mkIf (!isWSL) {
      boot.loader = {
        systemd-boot.enable = false;
        grub = {
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
        efi.efiSysMountPoint = efiMountPoint;
      };
      boot.kernelParams = [ "root=/dev/disk/by-partlabel/disk-main-root" ];
    })
    (lib.mkIf isWSL {
      boot.loader.grub.enable = lib.mkForce false;
      boot.loader.systemd-boot.enable = lib.mkForce false;
    })
  ];
}
