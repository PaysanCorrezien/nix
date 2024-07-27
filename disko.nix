{ config, lib, ... }:
let
  defaultDisk = lib.findFirst (disk: disk.type == "disk")
    (throw "No disk type device found!")
    (builtins.attrValues config.deviceTree.children);
in {
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = lib.mkDefault defaultDisk.path;
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              name = "boot";
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
}
