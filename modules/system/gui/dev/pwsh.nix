{ pkgs, lib, ... }:

let
  cfg = lib.mkIf (pkgs ? settings.isServer) pkgs.settings.isServer;
  powershell-editor-services = pkgs.fetchFromGitHub {
    owner = "PowerShell";
    repo = "PowerShellEditorServices";
    rev = "v3.20.1";  # Replace with the latest version
    sha256 = "sha256-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";  # Replace with the correct hash
  };
in
{
  pkgs = lib.mkIf (!cfg) {
    powershell-editor-services = pkgs.stdenv.mkDerivation {
      name = "powershell-editor-services";
      src = powershell-editor-services;

      dontBuild = true;  # No build needed, we're just copying files

      installPhase = ''
        mkdir -p $out
        cp -r $src/* $out/
      '';
    };
  };
}
