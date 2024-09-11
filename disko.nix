{ config, lib, ... }:

let
  cfg = config.settings.disko;
in
{
  options = {
    settings = lib.mkOption {
      type = lib.types.submodule {
        options = {
          disko = lib.mkOption {
            type = lib.types.submodule {
              options = {
                mainDisk = lib.mkOption {
                  type = lib.types.str;
                  description = "The main disk device (e.g., '/dev/vda')";
                  example = "/dev/sda";
                };
                layout = lib.mkOption {
                  type = lib.types.enum [ "standard" "vps" ];
                  default = "standard";
                  description = "Disk layout configuration";
                };
              };
            };
            description = "Disko-related settings";
          };
        };
      };
      description = "Global settings for the system";
    };
  };

  config = let
    efiMountPoint = if cfg.layout == "standard" then "/boot" else "/boot/efi";
    efiSize = if cfg.layout == "standard" then "500M" else "124M";
  in {
    disko.devices = {
      disk = {
        main = {
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
    };

    fileSystems = {
      "/" = lib.mkForce {
        device = "/dev/disk/by-partlabel/disk-main-root";
        fsType = "ext4";
      };
      ${efiMountPoint} = lib.mkForce {
        device = "/dev/disk/by-partlabel/disk-main-ESP";
        fsType = "vfat";
      };
    };
  };
}
