# disko-config.nix
# TODO: check luks x yubikey drive
#
{ config, lib, ... }:
let
  cfg = config.settings.disko;
  isWSL = config.wsl.enable or false;

  # Auto-detection logic
  scoreDrive = drive:
    if lib.hasPrefix "nvme" drive then 100
    else if lib.hasPrefix "vd" drive then 90
    else if lib.hasPrefix "sd" drive then 80
    else if lib.hasPrefix "xvd" drive then 60
    else if lib.hasPrefix "hd" drive then 50
    else if lib.hasPrefix "mmcblk" drive then 40
    else 0;

  isMainDrive = d:
    (lib.hasPrefix "nvme" d && lib.hasSuffix "n1" d) ||
    (lib.hasPrefix "sd" d && lib.stringLength d == 3) ||
    (lib.hasPrefix "vd" d && lib.stringLength d == 3) ||
    (lib.hasPrefix "xvd" d && lib.stringLength d == 4) ||
    (lib.hasPrefix "hd" d && lib.stringLength d == 3) ||
    (lib.hasPrefix "mmcblk" d && builtins.match "mmcblk[0-9]+" d != null);

  # Try to detect drives from /dev (works on same machine, fails gracefully otherwise)
  detectedDrive =
    let
      devContents = builtins.tryEval (builtins.readDir "/dev");
      drives = if devContents.success
        then builtins.attrNames devContents.value
        else [];
      validDrives = builtins.filter isMainDrive drives;
      sortedDrives = lib.sort (a: b: scoreDrive a > scoreDrive b) validDrives;
    in
    if builtins.length sortedDrives > 0
    then "/dev/${builtins.head sortedDrives}"
    else "/dev/sda";  # fallback
in
{
  options = {
    settings.disko = {
      mainDisk = lib.mkOption {
        type = lib.types.str;
        default = detectedDrive;
        description = "The main disk device (auto-detected if not specified)";
      };
      layout = lib.mkOption {
        type = lib.types.enum [
          "standard"
          "vps"
        ];
        default = "standard";
        description = "Disk layout configuration";
      };
      swap = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Whether to create a swap partition";
        };
        size = lib.mkOption {
          type = lib.types.str;
          default = "8G";
          description = "Size of swap partition (e.g., 8G, 16G)";
        };
      };
    };
  };

  config = lib.mkIf (!isWSL) (
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
            } // lib.optionalAttrs cfg.swap.enable {
              swap = {
                name = "swap";
                size = cfg.swap.size;
                content = {
                  type = "swap";
                };
              };
            } // {
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
    }
  );
}
