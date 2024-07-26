{ config, lib, pkgs, ... }:

let
  owner = "PaysanCorrezien";
  repo = "keybswitch";

  # Fetch the latest commit information
  latestCommit = builtins.fetchTree {
    type = "github";
    inherit owner repo;
    ref = "master";
  };

  keybswitch = pkgs.rustPlatform.buildRustPackage rec {
    pname = "keybswitch";
    version = "unstable-${builtins.substring 0 8 latestCommit.rev}";
    src = pkgs.fetchFromGitHub {
      inherit owner repo;
      rev = latestCommit.rev;
      hash = latestCommit.narHash;
    };

    cargoLock = { lockFile = "${src}/Cargo.lock"; };

    nativeBuildInputs = [
      pkgs.pkg-config
      pkgs.systemd # systemd provides libudev
      pkgs.openssl
      pkgs.libffi
    ];

    # Explicitly set PKG_CONFIG_PATH
    PKG_CONFIG_PATH =
      "${pkgs.systemd.dev}/lib/pkgconfig:${pkgs.openssl.dev}/lib/pkgconfig:${pkgs.libffi.dev}/lib/pkgconfig";

    meta = {
      description = "USB Keyboard Detection and Layout Switch";
      homepage = "https://github.com/${owner}/${repo}";
      license = lib.licenses.mit;
    };
  };
in {
  home.packages = [ keybswitch ];
  home.file.".config/autostart/keybswitch.desktop".text =
    lib.mkIf pkgs.stdenv.isLinux ''
      [Desktop Entry]
      Type=Application
      Exec=${keybswitch}/bin/keybswitch > /home/${config.home.username}/keybswitch.log 2>&1
      X-GNOME-Autostart-enabled=true
      Name=Keybswitch
      Comment=USB Keyboard Detection and Layout Switch
    '';
}
