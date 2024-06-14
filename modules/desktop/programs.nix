# here are the list of programs or dependencies for GUI setup #
{ config, pkgs, ... }:

{

  # Install keyboard-related packages
  environment.systemPackages = with pkgs; [

  thunderbird
firefox
  
rofi
keepassxc
todoist-electron
obsidian
discord
# WORK
remmina wireshark teamviewer 
# DEV
helix

  ];

    # List services that you want to enable:
  #NOTE: TODOIST 
  nixpkgs.config.permittedInsecurePackages = [
                "electron-25.9.0"
              ];


#NOTE: RDP to home computer
# Enable rdp for test purpose for now
services.xrdp.enable = true;
services.xrdp.openFirewall = true;
services.xrdp.defaultWindowManager = "startplasma-x11";
# https://github.com/NixOS/nixpkgs/issues/250533
environment.etc = {
  "xrdp/sesman.ini".source = "${config.services.xrdp.confDir}/sesman.ini";
};
}

