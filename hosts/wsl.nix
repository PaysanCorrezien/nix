# hosts/WSL.nix
{ config, lib, pkgs, inputs, ... }:
{
  imports = [
    inputs.nixos-wsl.nixosModules.wsl
  ];

  wsl = {
    enable = true;
    defaultUser = "dylan";
    nativeSystemd = true;
    usbip.enable = true;
    startMenuLaunchers = true;
    wslConf = {
      automount.enabled = true;
      network.hostname = "wsl";
      interop = {
        enabled = true;
        appendWindowsPath = true;
      };
    };
  };
  wsl.interop = {
    includePath = true;
    register = true;
  };
  services.udev.enable = lib.mkForce true;

  networking.hostName = "wsl";

  services.openssh.enable = lib.mkForce false;
  # Disable GUI-related services in WSL
  services.xserver.enable = false;
  services.pipewire.enable = false;

  # Disable unnecessary systemd services
  # systemd.services."systemd-timesyncd".enable = false;
  # systemd.services."systemd-udevd".enable = false;
  # services.timesyncd.enable = false;

  boot.isContainer = true;
  powerManagement.enable = lib.mkForce false;
  systemd.user.services.dbus = {
    wantedBy = [ "default.target" ];
  };

  # Allow users to use D-Bus
  security.polkit.enable = true;

  # Force boot loader configurations to be disabled in WSL
  boot.loader.grub.enable = lib.mkForce false;
  boot.loader.systemd-boot.enable = lib.mkForce false;

  settings = {
    username = "dylan";
    isServer = false;
    locale = "fr_FR.UTF-8";
    virtualisation.enable = false;
    # docker.enable = true;
    environment = "work";
    isExperimental = false;
    work = false;
    gaming = false;
    tailscale.enable = false;
    windowManager = null;
    displayServer = null;
    social.enable = false;
    architecture = "x86_64";
    autoSudo = false;
    hostname = "WSL";
    disko.mainDisk = "/dev/sda";
    sops = {
      enable = false;
      enableGlobal = false;
      machineType = "desktop";
    };
  };
  programs = {
    dconf.enable = false;

  };

  environment.systemPackages = with pkgs; [
    dbus
    docker
    docker-compose
    lazydocker
    # usbutils
    # jmtpfs
    # usbutils
    obsidian

  ];
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    # enableNvidia = true; # Enable NVIDIA runtime for Docker
    # rootless = {
    #   enable = true;
    #   setSocketVariable = true;
    # };
  };
  # boot.kernelModules = [ "usbip-core" "vhci-hcd" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ usbip ];
  programs.zsh = {
  enable = true;
  shellAliases = {
    sudo = "/run/wrappers/bin/sudo";
  };
};

  users.users.dylan = {
    extraGroups = [ "docker" "wheel" ];
  };

  systemd.services.polkit.enable = true;
  security.sudo.wheelNeedsPassword = false;

}
