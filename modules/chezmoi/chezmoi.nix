
{ pkgs, config, lib, ... }: let
  homeDir = config.home.homeDirectory;
in {
  home.packages = with pkgs; [
    chezmoi
  ];

  # home.activation.chezmoi = lib.hm.dag.entryAfter ["writeBoundary"] ''
  #   # Optional: Add colored echo messages to indicate the activation of chezmoi
  #   # echo -e "\033[0;34mActivating chezmoi\033[0m"
  #   # echo -e "\033[0;34m==================\033[0m"
  #   ${pkgs.chezmoi}/bin/chezmoi apply --verbose
  #   # echo -e "\033[0;34m==================\033[0m"
  # '';
}

# TODO: install from github on first init my dotfiles
# or sync otherwise with github
# chezmoi apply or update then on each rebuild
# handle error 
# if first init; initialize chezmoi templ w placeholder
