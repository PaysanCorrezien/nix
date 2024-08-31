{ lib, ... }:
let
  diskSelection = import ./drive.nix { inherit lib; };
  selectedDrive = diskSelection.selectedDrive;
in
{
  # Output debug information
  system.extraSystemBuilderCmds = ''
    echo '${diskSelection.debugInfo}' > /tmp/disko_debug_info.txt
  '';

  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = selectedDrive;
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
