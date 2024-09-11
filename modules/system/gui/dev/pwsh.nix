{ config, pkgs, lib, ... }:

let
  cfg = config.settings.isServer;
  powershell-editor-services = pkgs.stdenv.mkDerivation rec {
    pname = "powershell-editor-services";
    version = "3.20.1";
    src = pkgs.fetchFromGitHub {
      owner = "PowerShell";
      repo = "PowerShellEditorServices";
      rev = "v${version}";
      sha256 = "sha256-6RwqYi+4rLLXOBUQ9CuFG8AmV802IoOyO5+yOBlX+jQ=";
    };
    dontBuild = true;
    installPhase = ''
      runHook preInstall
      mkdir -p $out/modules/PowerShellEditorServices
      cp -r ./* $out/modules/PowerShellEditorServices/
      runHook postInstall
    '';
    meta = with lib; {
      description = "A common platform for PowerShell development support in editors and hosted applications";
      homepage = "https://github.com/PowerShell/PowerShellEditorServices";
      license = licenses.mit;
      platforms = platforms.all;
    };
  };
in
{
  
  config = lib.mkIf (!cfg) {
  nixpkgs.config.packageOverrides = pkgs: {
    powershell-editor-services = powershell-editor-services;
  };

  environment.systemPackages = with pkgs; [
    powershell
    powershell-editor-services
  ];

  # Set the environment variable for Zsh
  programs.zsh = {
    interactiveShellInit = ''
      export POWERSHELL_EDITOR_SERVICES_PATH="${powershell-editor-services}"
    '';
  };

  # Optionally, you can also set it for other shells if needed
  environment.shellInit = ''
    export POWERSHELL_EDITOR_SERVICES_PATH="${powershell-editor-services}"
  '';
};
}
