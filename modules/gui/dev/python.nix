{ config, pkgs, ... }:

let
  pythonWithPackages = pkgs.python3.withPackages (ps: with ps; [
    pillow
    pyperclip
    requests
    pkgs.python3Packages.pygobject3
    pkgs.python3Packages.pycairo
    pkgs.python3Packages.pyyaml
    
  ]);
in
{
  # Install Python with required packages and Espanso
  environment.systemPackages = with pkgs; [
    pythonWithPackages
    gtk3
  ];
}
