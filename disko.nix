{config, lib, ... }:

let
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

# potentialDrives = builtins.trace "Potential drives: ${builtins.toString potentialDrives}" (

  allPossibleDrives = 
    (map (i: "/dev/nvme${toString i}n1") (lib.range 0 7)) ++
    (map (c: "/dev/sd${c}") (lib.stringToCharacters "abcdefghijklmnop")) ++
    (map (c: "/dev/vd${c}") (lib.stringToCharacters "abcdefghijklmnop")) ++
    (map (c: "/dev/xvd${c}") (lib.stringToCharacters "abcdefghijklmnop")) ++
    (map (c: "/dev/hd${c}") (lib.stringToCharacters "abcdefghijklmnop")) ++
    (map (i: "/dev/mmcblk${toString i}") (lib.range 0 9)) ++
    (map (i: "/dev/loop${toString i}") (lib.range 0 7)) ++
    (map (i: "/dev/sr${toString i}") (lib.range 0 3)) ++
    (map (i: "/dev/fd${toString i}") (lib.range 0 3));

  potentialDrives = lib.filter (drive: builtins.pathExists drive) allPossibleDrives;

  debugPotentialDrives = builtins.trace "Potential drives: ${builtins.toString potentialDrives}" potentialDrives;


  # Function to select the best drive
  selectBestDrive = drives:
  let
    scoredDrives = map (drive: { name = drive; score = scoreDrive (lib.last (lib.splitString "/" drive)); }) drives;
    sortedDrives = lib.sort (a: b: a.score > b.score) scoredDrives;
  in
  builtins.trace "Scored drives: ${builtins.toJSON scoredDrives}"
    (if builtins.length sortedDrives > 0
     then (builtins.head sortedDrives).name
     else throw "No suitable drive found for installation. Please check your hardware configuration.");

in
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = lib.mkDefault (selectBestDrive debugPotentialDrives);
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
    echo "[Disko] Installation drive: $(readlink -f ${config.disko.devices.disk.main.device})"
    echo "[Disko] Root partition: $(readlink -f /dev/disk/by-partlabel/disk-main-root)"
    echo "[Disko] Boot partition: $(readlink -f /dev/disk/by-partlabel/disk-main-ESP)"
  '';
}
