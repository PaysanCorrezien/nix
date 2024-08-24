{ config, pkgs, inputs, ... }:

{
  environment.systemPackages = with pkgs; [
    pinentry-tty
    starship
    tldr
    xclip
    git
    fzf
    zoxide
    fd
    yazi
    lsd
    unzip
    bc # for math calculations on shell
    zip
    ripgrep
    wget
  ];
}

