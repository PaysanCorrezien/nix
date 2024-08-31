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
    builtins.filter (d:
      builtins.pathExists ("/dev/" + d) &&
      (lib.hasPrefix "nvme" d || lib.hasPrefix "sd" d || lib.hasPrefix "vd" d || 
       lib.hasPrefix "xvd" d || lib.hasPrefix "hd" d || lib.hasPrefix "mmcblk" d) &&
      !(lib.hasSuffix "p" d) &&  # Exclude partition devices
      d != "nbd0"  # Exclude network block device
    ) (builtins.attrNames (builtins.readDir /dev));

  # Find the best drive
  bestDrive = "/dev/" + lib.head (lib.sort (a: b: scoreDrive a > scoreDrive b) availableDrives);

  # Debug information
  debugInfo = ''
    Available drives: ${builtins.toString availableDrives}
    Selected drive: ${bestDrive}
  '';
in
{
  # Output debug information
  system.extraSystemBuilderCmds = ''
    echo '${debugInfo}' > $out/disko-debug-info.txt
  '';

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
}
