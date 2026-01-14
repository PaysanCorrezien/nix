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
          useOSProber = true;
          extraEntries = ''
            ## ── Power controls ───────────────────────────────────────────────
            menuentry "Reboot"   { reboot }
            menuentry "Power-off" { halt }

            ## ── Maintenance / debugging ─────────────────────────────────────
            # press ‘c’ from the GRUB menu for a shell,
            #  press ‘e’ on any entry to edit its kernel command line.

            menuentry "Enter firmware setup (UEFI / BIOS)" {
              fwsetup
            }

            menuentry "Boot first USB device" {
              set root=(hd1)
              chainloader +1
            }
          '';
        };
        efi.efiSysMountPoint = efiMountPoint;
      };
      boot.kernelParams = [ "boot.shell_on_fail" "boot.trace" "root=/dev/disk/by-partlabel/disk-main-root" ];

    })
    (lib.mkIf isWSL {
      boot.loader.grub.enable = lib.mkForce false;
      boot.loader.systemd-boot.enable = lib.mkForce false;
    })
  ];
}
