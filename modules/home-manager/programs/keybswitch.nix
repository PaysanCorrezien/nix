{ config, lib, pkgs, ... }:

let
  keybswitch = pkgs.rustPlatform.buildRustPackage rec {
    pname = "keybswitch";
    version = "unstable-2024-07-08";

    src = pkgs.fetchFromGitHub {
      owner = "PaysanCorrezien";
      repo = pname;
      rev = "c35b144b4f62f1ed8d161aa880c9d7bba58f7288";
      sha256 = "bdAsASlqgwErbxaITOfscaPBQfyykWDqDe6rjr0rX58=";
    };

    cargoSha256 = "jaTMT9GkWyPXFb2Seuk6bD1uPgW8jHeAgEnQUnM9/Mk=";

    nativeBuildInputs = [
      pkgs.pkg-config
      pkgs.systemd  # systemd provides libudev
      pkgs.openssl
      pkgs.libffi
    ];

    # Explicitly set PKG_CONFIG_PATH
    PKG_CONFIG_PATH = "${pkgs.systemd.dev}/lib/pkgconfig:${pkgs.openssl.dev}/lib/pkgconfig:${pkgs.libffi.dev}/lib/pkgconfig";

    meta = {
      description = "USB Keyboard Detection and Layout Switch";
      homepage = "https://github.com/PaysanCorrezien/keybswitch";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ ];
    };
  };
in
{
  home.packages = [ keybswitch ];

  home.file.".config/autostart/keybswitch.desktop".text = lib.mkIf pkgs.stdenv.isLinux ''
    [Desktop Entry]
    Type=Application
    Exec=${keybswitch}/bin/keybswitch > /home/${config.home.username}/keybswitch.log 2>&1
    X-GNOME-Autostart-enabled=true
    Name=Keybswitch
    Comment=USB Keyboard Detection and Layout Switch
  '';
}
