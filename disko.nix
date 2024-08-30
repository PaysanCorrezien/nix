{ lib, ... }:
let
  # Expanded function to score drives based on type and performance expectations
  scoreDrive = drive:
    if lib.hasPrefix "nvme" drive then 100
    else if lib.hasPrefix "sd" drive then 80
    else if lib.hasPrefix "vd" drive then 70  # Virtual drives
    else if lib.hasPrefix "xvd" drive then 60 # Xen virtual drives
    else if lib.hasPrefix "hd" drive then 50  # IDE drives
    else if lib.hasPrefix "mmcblk" drive then 40 # SD cards / eMMC
    else if lib.hasPrefix "loop" drive then 30 # Loopback devices
    else if lib.hasPrefix "sr" drive then 20   # Optical drives
    else if lib.hasPrefix "fd" drive then 10   # Floppy drives
    else 0; # Any other type of drive

  # Find all available drives, excluding nvme0
  availableDrives =
    builtins.filter (d: builtins.pathExists ("/dev/" + d) && d != "nvme0")
      (builtins.attrNames (builtins.readDir /dev));

  # Find the best drive, considering all types
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
              size = "500M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
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
  # Override the conflicting fileSystems configurations
  fileSystems = {
    "/" = lib.mkForce {
      device = "/dev/disk/by-partlabel/root";
      fsType = "ext4";
    };
    "/boot" = lib.mkForce {
      device = "/dev/disk/by-partlabel/ESP";
      fsType = "vfat";
    };
  };
}
