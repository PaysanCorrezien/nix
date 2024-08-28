{ config, lib, pkgs, inputs, ... }:

let cfg = config.settings.isServer;
  makeDesktopFile = { name, exec, comment }:
    pkgs.writeText "${name}.desktop" ''
      [Desktop Entry]
      Type=Application
      Name=${name}
      Exec=${exec}
      Comment=${comment}
      Icon=utilities-terminal
      Terminal=false
      Categories=Utility;
    '';

  home-clovis-desktop = makeDesktopFile {
    name = "Home Clovis";
    exec = "${clovis-pkg}/bin/clovis launch home";
    comment = "Launch Clovis with home configuration";
  };

  work-clovis-desktop = makeDesktopFile {
    name = "Work Clovis";
    exec = "${clovis-pkg}/bin/clovis launch work";
    comment = "Launch Clovis with work configuration";
  };
  clovis-pkg = inputs.clovis.packages.${pkgs.system}.default;
in
{
  
  imports = [ inputs.clovis.nixosModules.default ];
  config = lib.mkIf (!cfg) {

  # Create the .desktop files and place them in the applications directory
  environment.systemPackages = [
    clovis-pkg
    (pkgs.runCommand "clovis-desktop-files" { } ''
      mkdir -p $out/share/applications
      cp ${home-clovis-desktop} $out/share/applications/home-clovis.desktop
      cp ${work-clovis-desktop} $out/share/applications/work-clovis.desktop
    '')
  ];
  };

}

