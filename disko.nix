{ lib, ... }:
let
  # Function to score drives, preferring NVMe
  scoreDrive = drive:
  if lib.hasPrefix "nvme" drive then 100
  else if lib.hasPrefix "sd" drive then 80
  else if lib.hasPrefix "vd" drive then 70  # Virtual drives
  else if lib.hasPrefix "xvd" drive then 60 # Xen virtual drives
  else if lib.hasPrefix "hd" drive then 50  # IDE drives
  else if lib.hasPrefix "mmcblk" drive then 40 # SD cards / eMMC
  else 0; # Any other type of drive

# Find all available drives
availableDrives =
  builtins.filter (d: builtins.pathExists ("/dev/" + d))
    (builtins.attrNames (builtins.readDir /dev));

# Find the best drive
bestDrive = "/dev/" + lib.head (lib.sort (a: b: scoreDrive a > scoreDrive b)
  (builtins.filter (d: 
    lib.hasPrefix "nvme" d || 
    lib.hasPrefix "sd" d || 
    lib.hasPrefix "vd" d || 
    lib.hasPrefix "xvd" d || 
    lib.hasPrefix "hd" d || 
    lib.hasPrefix "mmcblk" d
  ) availableDrives));
in
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = bestDrive;
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              name = "ESP";
              start = "1MiB";
              end = "512MiB";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              name = "root";
              start = "512MiB";
              end = "100%";
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
  # Override the conflicting fileSystems configurations
  fileSystems = {
    "/" = lib.mkForce {
      device = "/dev/disk/by-partlabel/disk-main-root";
      fsType = "ext4";
    };
    "/boot" = lib.mkForce {
      device = "/dev/disk/by-partlabel/disk-main-ESP";
      fsType = "vfat";
      options = [ "umask=0077" "dmask=0077" "fmask=0077" ];
    };
  };
}


