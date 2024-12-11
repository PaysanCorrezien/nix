# disko-config.nix
# TODO: check luks x yubikey drive
# TODO: make back the default detection script, and provide options to use differents layouts preset ( cloud vps / nvme computer)
#
{ config, lib, ... }:
let
  cfg = config.settings.disko;
in
{
  options = {
    settings.disko = {
      mainDisk = lib.mkOption {
        type = lib.types.str;
        description = "The main disk device";
      };
      layout = lib.mkOption {
        type = lib.types.enum [
          "standard"
          "vps"
        ];
        default = "standard";
        description = "Disk layout configuration";
      };
    };
  };

  config =
    let
      efiMountPoint = if cfg.layout == "standard" then "/boot" else "/boot/efi";
      efiSize = if cfg.layout == "standard" then "500M" else "124M";
    in
    {
      disko.devices = {
        disk.main = {
          type = "disk";
          device = cfg.mainDisk;
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                name = "ESP";
                size = efiSize;
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = efiMountPoint;
                };
              };
              root = {
                name = "root";
                size = "100%";
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/";
                };
              };
            };
          };
        };
      };

      # Define filesystems without mkForce
      fileSystems = {
        "/" = {
          device = "/dev/disk/by-partlabel/disk-main-root";
          fsType = "ext4";
          neededForBoot = true;
        };
        ${efiMountPoint} = {
          device = "/dev/disk/by-partlabel/disk-main-ESP";
          fsType = "vfat";
          depends = [ "/" ];
        };
      };
    };
}
