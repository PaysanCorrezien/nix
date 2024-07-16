# modules/common.nix
{ inputs, config, pkgs, ... }:

{
  imports = [ /etc/nixos/hardware-configuration.nix ./keyboard.nix ];

  system.stateVersion = "24.05";

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Paris";

  i18n.defaultLocale = "fr_FR.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  # Configure console keymap
  #TODO: console alt depending on keyboard udev rules ?
  console.keyMap = "fr";

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  services.openssh.enable = true;

  users.users.dylan = {
    isNormalUser = true;
    description = "dylan";
    extraGroups = [ "i2c" "networkmanager" "wheel" "libvirtd" "kvm" ];
    # libvirtd et kvm oour virtualisation.nix ( a deplacer)
  };
  #cant be in HM fix this
  users.users.dylan.shell = pkgs.zsh;
  programs.zsh.enable = true;

  services.udev.extraRules = ''
    KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"
  '';
  hardware.i2c.enable = true;
  boot.kernelModules = [ "i2c-dev" ];

  #home manager enable
  home-manager = {
    # also pass inputs to home-manager modules
    extraSpecialArgs = { inherit inputs; };
    backupFileExtension =
      "HomeManagerBAK"; # https://discourse.nixos.org/t/way-to-automatically-override-home-manager-collisions/33038/3
    users = { "dylan" = import ../modules/home-manager/home.nix; };
    # https://github.com/nix-community/home-manager/issues/1213
    # TODO: test this
    # xdg.configFile."mimeapps.list".force = true;
  };
}

