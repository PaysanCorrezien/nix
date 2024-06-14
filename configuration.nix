# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs,inputs, ... }:

{
  imports =
  [ # Include the results of the hardware scan.
     "/etc/nixos/hardware-configuration.nix"
     inputs.home-manager.nixosModules.default
     ];

  # Bootloader.
#  boot.loader.grub.enable = true;
  # FIXME: THIS need to be automatically set to be use on various computers
 # boot.loader.grub.device = "nodev";
  # boot.loader.grub.useOSProber = true;
 # boot.loader.grub.efiSupport = true;

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

#  console.keyMap = "us-acentos";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.dylan = {
    isNormalUser = true;
    description = "dylan";
    extraGroups = [ "networkmanager" "wheel" ];
#    packages = with pkgs; [
#    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #x11 temp
  xorg.xinit
##
tailscale
#
docker
pandoc
#TODO: forticlient vpn
python3
pyenv
nextcloud-client

lsd

# ollama #TODO : setup ollama /machine (light model on laptop : whisper / phi / translation)

  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
   programs.mtr.enable = true;
   programs.gnupg.agent = {
     enable = true;
     enableSSHSupport = true;
   };

# TODO: SSH.nix with hardened setup no passwd / 
  # Enable the OpenSSH daemon.
   services.openssh.enable = true;

  #home manager enable
  home-manager = {
  # also pass inputs to home-manager modules
  extraSpecialArgs = {inherit inputs;};
  users = {
    "dylan" = import ./modules/home-manager/home.nix;
  };
};

}
