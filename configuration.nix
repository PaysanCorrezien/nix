# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    # "/etc/nixos/hardware-configuration.nix"
    inputs.home-manager.nixosModules.default
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    # tigervnc  
    neovim
    sqlite
    nil # LSP for nix
    haskellPackages.nixfmt
    # nodejs_21
    nodePackages.npm
    nodejs

    pinentry-tty

    wget
    #x11 temp
    xorg.xinit
    xclip
    ##
    wezterm
    git
    starship
    fzf
    zoxide
    bat
    ripgrep
    neofetch
    zsh
    fd
    shell-gpt
    gum
    zsh-fzf-tab
    zsh-forgit

    obsidian
    discord
    # WORK
    powershell
    # DEV
    helix
    tailscale

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
    pyenv
    nextcloud-client

    zig
    # libgcc
    lsd
    libnotify
    ripgrep-all

    nil
    gitui
    stylua
    unzip
    gcc

    ollama
    zip
    espanso

    todoist
    flameshot

    # gnome.adwaita-icon-theme
    # xorg.xcursorthemes
    # WORK : 
    microsoft-edge
    linphone
    openfortivpn
    remmina
    wireshark
    teamviewer

    ddcutil # attempt to control momitor
    ddcui
    gnomeExtensions.brightness-control-using-ddcutil
    gitleaks

  ];

}
