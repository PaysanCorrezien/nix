{ config, pkgs, ... }:

{
  # Font configuration using Home Manager
  home.packages = with pkgs; [
    # Adding Fira Code Nerd Font using the override function
   (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
    # Other fonts or packages as needed
    monaspace
  ];
}

