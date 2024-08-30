{ lib, ... }:
let
  # Function to score drives based on type and performance expectations
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
    builtins.filter (d: builtins.pathExists ("/dev/" + d) && d != "nvme0")
      (builtins.attrNames (builtins.readDir /dev));

  # Find the best drive, with a fallback
  bestDrive = 
    let
      validDrives = builtins.filter (d: 
        lib.hasPrefix "nvme" d || 
        lib.hasPrefix "sd" d || 
        lib.hasPrefix "vd" d ||
        lib.hasPrefix "xvd" d ||
        lib.hasPrefix "hd" d ||
        lib.hasPrefix "mmcblk" d
      ) availableDrives;
      sortedDrives = lib.sort (a: b: scoreDrive a > scoreDrive b) validDrives;
    in
      if builtins.length sortedDrives > 0
      then "/dev/" + (builtins.head sortedDrives)
      else "/dev/sda";  # Fallback to a common default if no drives are found

  # Use traceSeq to provide feedback
  _ = lib.traceSeq ["[Disko] Selected drive for installation: ${bestDrive}"] null;
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
              name = "disk-main-ESP";
              size = "500M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              name = "disk-main-root";
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

  # Filesystem configurations
  fileSystems = {
    "/" = lib.mkForce {
      device = "/dev/disk/by-partlabel/disk-main-root";
      fsType = "ext4";
    };
    "/boot" = lib.mkForce {
      device = "/dev/disk/by-partlabel/disk-main-ESP";
      fsType = "vfat";
    };
  };

  # Provide feedback on configuration
  system.activationScripts.diskoReport = ''
    echo "[Disko] Installation drive: ${bestDrive}"
    echo "[Disko] Root partition: $(readlink -f /dev/disk/by-partlabel/disk-main-root)"
    echo "[Disko] Boot partition: $(readlink -f /dev/disk/by-partlabel/disk-main-ESP)"
  '';
}
