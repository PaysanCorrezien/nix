# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs,inputs, ... }:

{
  imports =
  [ # Include the results of the hardware scan.
     # "/etc/nixos/hardware-configuration.nix"
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
    packages = with pkgs; [
      firefox
      thunderbird

    ];
  };

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "dylan";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  # tigervnc  
  neovim
  sqlite
  nil #LSP for nix
  # dev 
  nodejs_21
  nodePackages.npm

  wget
  #x11 temp
  xorg.xinit
  xclip
##
  wezterm
  git
starship
fzf zoxide bat ripgrep neofetch zsh fd shell_gpt gum 
zsh-fzf-tab
zsh-forgit

obsidian
discord
# WORK
remmina wireshark teamviewer 
powershell
# KEYBOARD 
vial qmk qmk_hid keymapviz
# DEV
helix
tailscale

#TODO : replace this with  real setup
rustup
rustc
cargo
#
todoist-electron
rofi
nodenv
jdk21
ffmpeg
btop
docker
pandoc
yazi
tokei
gh
github-copilot-cli
keepassxc
#TODO: forticlient vpn
python3
pyenv
nextcloud-client

lsd
ollama

  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
   programs.mtr.enable = true;
   programs.gnupg.agent = {
     enable = true;
     enableSSHSupport = true;
   };
  # List services that you want to enable:
  #NOTE: TODOIST 
  nixpkgs.config.permittedInsecurePackages = [
                "electron-25.9.0"
              ];

  # Enable the OpenSSH daemon.
   services.openssh.enable = true;
# Enable rdp for test purpose for now
services.xrdp.enable = true;
services.xrdp.openFirewall = true;
services.xrdp.defaultWindowManager = "startplasma-x11";
# https://github.com/NixOS/nixpkgs/issues/250533
environment.etc = {
  "xrdp/sesman.ini".source = "${config.services.xrdp.confDir}/sesman.ini";
};


  #home manager enable
  home-manager = {
  # also pass inputs to home-manager modules
  extraSpecialArgs = {inherit inputs;};
  users = {
    "dylan" = import ./modules/home-manager/home.nix;
  };
};

}
