{ lib }:
let
  scoreDrive = drive:
    if lib.hasPrefix "nvme" drive then 100
    else if lib.hasPrefix "sd" drive then 80
    else if lib.hasPrefix "vd" drive then 70  # Virtual drives
    else if lib.hasPrefix "xvd" drive then 60 # Xen virtual drives
    else if lib.hasPrefix "hd" drive then 50  # IDE drives
    else if lib.hasPrefix "mmcblk" drive then 40 # SD cards / eMMC
    else 0; # Any other type of drive

  isMainDrive = d:
    (lib.hasPrefix "nvme" d && lib.hasSuffix "n1" d) ||
    (lib.hasPrefix "sd" d && lib.stringLength d == 3) ||
    (lib.hasPrefix "vd" d && lib.stringLength d == 3) ||
    (lib.hasPrefix "xvd" d && lib.stringLength d == 4) ||
    (lib.hasPrefix "hd" d && lib.stringLength d == 3) ||
    (lib.hasPrefix "mmcblk" d && !(lib.hasSuffix "p" d));

  availableDrives = 
    builtins.filter (d:
      builtins.pathExists ("/dev/" + d) &&
      isMainDrive d
    ) (builtins.attrNames (builtins.readDir /dev));

  bestDrive = lib.head (lib.sort (a: b: scoreDrive a > scoreDrive b) availableDrives);

  debugInfo = ''
    Available drives: ${builtins.toString availableDrives}
    Drive scores: ${builtins.toString (map (d: "${d}: ${toString (scoreDrive d)}") availableDrives)}
    Selected drive: ${if bestDrive != null then "/dev/" + bestDrive else "No drive found"}
  '';
in
{
  inherit availableDrives debugInfo;
  selectedDrive = if bestDrive != null then "/dev/" + bestDrive else null;
}
