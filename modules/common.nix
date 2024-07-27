# modules/common.nix
{ inputs, config, pkgs, lib, ... }:
#NOTE: home manager cant inherit config it fail with darwin error
let settings = config.settings;

in {
  imports = [
    inputs.home-manager.nixosModules.default
    # FIXME: this require to use --impure
    # /etc/nixos/hardware-configuration.nix
    ./keyboard.nix
    # Conditionally import hardware-configuration.nix if it exists
    (lib.mkIf (builtins.pathExists /etc/nixos/hardware-configuration.nix)
      /etc/nixos/hardware-configuration.nix)
  ];

  system.stateVersion = "24.05";

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Paris";

  i18n = {
    defaultLocale = settings.locale;
    extraLocaleSettings = {
      LC_ADDRESS = settings.locale;
      LC_IDENTIFICATION = settings.locale;
      LC_MEASUREMENT = settings.locale;
      LC_MONETARY = settings.locale;
      LC_NAME = settings.locale;
      LC_NUMERIC = settings.locale;
      LC_PAPER = settings.locale;
      LC_TELEPHONE = settings.locale;
      LC_TIME = settings.locale;
    };
  };

  # Configure console keymap

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  users.users.dylan = {
    isNormalUser = true;
    description = "dylan";
    extraGroups = [ "i2c" "networkmanager" "wheel" ];
  };

  #cant be in HM fix this
  users.users.dylan.shell = pkgs.zsh;
  programs.zsh.enable = true;

  services.udev.extraRules = ''
    KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"
  '';
  hardware.i2c.enable = true;
  boot.kernelModules = [ "i2c-dev" ];

  home-manager = {
    extraSpecialArgs = { inherit inputs settings; };
    backupFileExtension =
      "HomeManagerBAK"; # https://discourse.nixos.org/t/way-to-automatically-override-home-manager-collisions/33038/3
    users = { "dylan" = import ../modules/home-manager/home.nix; };
  };
}

