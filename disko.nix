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
  # {
  #   disko.devices = {
  #     disk = {
  #       my-disk = {
  #         device = "/dev/sda";
  #         type = "disk";
  #         content = {
  #           type = "gpt";
  #           partitions = {
  #             ESP = {
  #               type = "EF00";
  #               size = "500M";
  #               content = {
  #                 type = "filesystem";
  #                 format = "vfat";
  #                 mountpoint = "/boot";
  #               };
  #             };
  #             root = {
  #               size = "100%";
  #               content = {
  #                 type = "filesystem";
  #                 format = "ext4";
  #                 mountpoint = "/";
  #               };
  #             };
  #           };
  #         };
  #       };
  #     };
  #   };
  # }
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
              sixe = "500M";
              # start = "1MiB";
              # end = "512MiB";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              # start = "513MiB";
              # end = "100%";
              size = "100%";
              # type = "8300";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
                # extraArgs = [ "-L" "nixos" ];
              };
            };
          };
        };
      };
    };
  };
}
