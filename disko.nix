{ lib, ... }:
let
  # Function to score drives based on type and performance expectations
  scoreDrive = drive:
    if lib.hasPrefix "nvme" drive then 100  # NVMe drives (including NVMe M.2)
    else if lib.hasPrefix "sd" drive && (lib.hasInfix "ssd" drive || lib.hasInfix "m2" drive) then 90  # SATA SSDs and M.2 SATA drives
    else if lib.hasPrefix "sd" drive then 80  # Regular SATA drives
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
  fileSystems = lib.mkMerge [
    (lib.traceSeq ["[Disko] Configuring root filesystem"] {
      "/" = lib.mkForce {
        device = "/dev/disk/by-partlabel/disk-main-root";
        fsType = "ext4";
      };
    })
    (lib.traceSeq ["[Disko] Configuring boot filesystem"] {
      "/boot" = lib.mkForce {
        device = "/dev/disk/by-partlabel/disk-main-ESP";
        fsType = "vfat";
      };
    })
  ];
}
