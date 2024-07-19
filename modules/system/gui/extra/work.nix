{ config, pkgs, lib, ... }:

let
  cfg = config.settings;
  # TODO: prepare an automount script for drive 
  # configure powershell modules ?
  # TODO: nix doest provite any settings for it . and i have psfzf as mandatory dep
in {
  config = lib.mkIf cfg.work {
    environment.systemPackages = with pkgs; [
      microsoft-edge
      linphone
      openfortivpn
      remmina
      wireshark
      teamviewer
      vscode-extensions.ms-vscode.powershell # lsp for neovim
    ];
  };
}

