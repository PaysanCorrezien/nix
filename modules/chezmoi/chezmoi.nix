{ config, pkgs, lib, ... }:

let
  chezmoiUpdateScript = pkgs.writeShellScriptBin "update-dotfiles" ''
    #!/bin/bash
    ${builtins.readFile ../../scripts/chezmoi.sh}
  '';
in
{
  home.packages = with pkgs; [ chezmoi chezmoiUpdateScript ];

  # Make the script directly accessible
  home.file.".local/bin/update-dotfiles".source =
    "${chezmoiUpdateScript}/bin/update-dotfiles";
}
