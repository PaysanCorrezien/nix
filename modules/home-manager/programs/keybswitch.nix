{ config, pkgs, lib, ... }:

let
  keybswitchRepo = "https://github.com/PaysanCorrezien/keybswitch";
  keybswitchBinaryPath = "/home/${config.home.username}/repo/keybswitch/target/release/keybswitch";

  keybswitchScript = pkgs.writeShellScriptBin "keybswitch" ''
    # Start keybswitch binary
    ${keybswitchBinaryPath}
  '';
in
{
  # Create the .desktop file in autostart directory
  home.file.".config/autostart/keybswitch.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Exec=${keybswitchBinaryPath}
    Hidden=true
    NoDisplay=true
    X-GNOME-Autostart-enabled=true
    Name=Keybswitch
    Comment=USB Keyboard Detection and Layout Switch
  '';

  # Ensure the binary is executable
  home.activation = {
    keybswitch = {
      run = ''
        chmod +x ${keybswitchBinaryPath}
      '';
    };

    # Fetch from GitHub and build if the binary is not present
    fetchAndBuildKeybswitch = lib.mkIf (!builtins.pathExists keybswitchBinaryPath) {
      run = ''
        echo "Fetching and building keybswitch..."
        git clone ${keybswitchRepo} /tmp/keybswitch
        cd /tmp/keybswitch
        cargo build --release
        mkdir -p $(dirname ${keybswitchBinaryPath})
        cp target/release/keybswitch ${keybswitchBinaryPath}
        chmod +x ${keybswitchBinaryPath}
      '';
    };
  };
}
