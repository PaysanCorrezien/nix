{ lib, ... }:
let
  # Function to score drives, preferring NVMe
  scoreDrive = drive:
    if lib.hasPrefix "nvme" drive then
      100
    else if lib.hasPrefix "sd" drive then
      50
    else
      0;
  # Find all available drives
  availableDrives =
    builtins.filter (d: builtins.pathExists ("/dev/" + d) && d != "nvme0")
    (builtins.attrNames (builtins.readDir /dev));
  # Find the best drive
  bestDrive = "/dev/" + lib.head (lib.sort (a: b: scoreDrive a > scoreDrive b)
    (builtins.filter (d: lib.hasPrefix "nvme" d || lib.hasPrefix "sd" d)
      availableDrives));
in {
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
                # Remove the label setting or use a shorter label
                extraArgs = [ "-L" "nixos" ]; # Shorter label
              };
            };
          };
        };
      };
    };
  };
}
