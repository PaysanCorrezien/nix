# ZFS configuration with fixed sanoid settings
{ config, lib, pkgs, ... }:
let
  hostHash = lib.mkDefault (builtins.substring 0 8 (builtins.hashString "md5" config.networking.hostName));
  username = config.settings.username;
  dockerDataset = "docker-storage/docker";
  dockerMountpoint = "/home/${username}/docker";
  poolExists = builtins.pathExists "/dev/zfs/docker-storage";
in
{
  # Core ZFS support remains the same
  boot = {
    supportedFilesystems = [ "zfs" ];
    kernelModules = [ "zfs" ];
    extraModulePackages = with config.boot.kernelPackages; [ zfs ];
    
    zfs = {
      forceImportAll = false;
      forceImportRoot = false;
    };
  };

  networking.hostId = hostHash;

  environment.systemPackages = with pkgs; [
    zfs
    zfstools
    smartmontools
    sanoid
  ];

  # ZFS service configuration
  services.zfs = {
    autoScrub = {
      enable = true;
      interval = "monthly";
      pools = [ "docker-storage" ];
      randomizedDelaySec = "1h";
    };

    trim = {
      enable = true;
      interval = "weekly";
      randomizedDelaySec = "1h";
    };
  };

  # Fixed sanoid configuration
  services.sanoid = {
    enable = true;
    interval = "hourly";
    # Define a template first
    templates.production = {
      hourly = 24;
      daily = 7;
      weekly = 4;
      monthly = 12;
      yearly = 0;
      autosnap = true;
      autoprune = true;
    };
    # Use the template for the dataset
    datasets."docker-storage/docker" = {
      useTemplate = ["production"];
      recursive = true;
      processChildrenOnly = false;
    };
  };

  # Filesystem mount
  fileSystems = lib.mkIf poolExists {
    ${dockerMountpoint} = {
      device = dockerDataset;
      fsType = "zfs";
      options = [ "zfsutil" ];
      neededForBoot = false;
    };
  };

  # Tmpfiles configuration
  systemd.tmpfiles.rules = lib.mkIf (builtins.pathExists dockerMountpoint) [
    "d ${dockerMountpoint} 0755 ${username} users - -"
  ];
}
