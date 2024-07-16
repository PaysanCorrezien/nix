{ config, pkgs, inputs, ... }:

{
  environment.systemPackages = with pkgs; [
    pinentry-tty
    starship
    xclip
    git
    fzf
    zoxide
    fd
    # zsh-fzf-tab
    yazi
    lsd
    unzip
    zip
    # zsh-forgit
    # bat
    ripgrep
    wget
    # TODO: work on taiscale autosetup for all device 
    tailscale
  ];
}

