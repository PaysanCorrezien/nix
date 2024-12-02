{
  inputs,
  plasma-manager,
  config,
  pkgs,
  system,
  lib,
  nixpkgs,
  ...
}:
#NOTE: home manager cant inherit config it fail with darwin error
let
  settings = config.settings;
in
{
  imports = [
    inputs.home-manager.nixosModules.default
    # FIXME: this require to use --impure
    # /etc/nixos/hardware-configuration.nix
    ./keyboard.nix
    ./sudoers.nix
  ];
  system.stateVersion = "24.05";
  time.timeZone = "Europe/Paris";
  i18n = {
    defaultLocale = settings.locale;
    extraLocaleSettings = {
      LC_ADDRESS = settings.locale;
      LC_IDENTIFICATION = settings.locale;
      LC_MEASUREMENT = settings.locale;
      LC_MONETARY = settings.locale;
      LC_NAME = settings.locale;
      LC_NUMERIC = settings.locale;
      LC_PAPER = settings.locale;
      LC_TELEPHONE = settings.locale;
      LC_TIME = settings.locale;
    };
  };

  # Configure console keymap
  nixpkgs.config.allowUnfree = true;
  hardware.firmware = [
    pkgs.firmwareLinuxNonfree
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  # NOTE: attempt to make computer wifi card work
  # move this to specific host conf if work
  hardware.enableAllFirmware = true;
  users.users.dylan = {
    isNormalUser = true;
    description = "dylan";
    extraGroups = [
      "i2c"
      "networkmanager"
      "wheel"
    ];
  };
  #cant be in HM fix this
  users.users.dylan.shell = pkgs.zsh;
  programs.zsh.enable = true;
  services.udev.extraRules = ''
    KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"
  '';
  hardware.i2c.enable = true;
  boot.kernelModules = [ "i2c-dev" ];
  home-manager = {
    extraSpecialArgs = {
      inherit inputs settings system;
      hostName = config.networking.hostName;
    };
    backupFileExtension = "HomeManagerBAK"; # https://discourse.nixos.org/t/way-to-automatically-override-home-manager-collisions/33038/3
    users = {
      "dylan" = import ../modules/home-manager/home.nix;
    };
    sharedModules = [
      #   inputs.sops-nix.homeManagerModules.sops
      {
        nixpkgs.overlays = [
          # inputs.hyprpanel.overlay
          (
            final: prev:
            let
              baseHyprpanel =
                (prev.callPackage "${inputs.hyprpanel}/nix" {
                  inputs = inputs // {
                    ags = {
                      packages.${prev.system}.default = {
                        override = _: prev.ags;
                      };
                    };
                  };
                }).desktop.script;
            in
            {
              hyprpanel = prev.symlinkJoin {
                name = "hyprpanel";
                paths = [ baseHyprpanel ];
                buildInputs = [ prev.makeWrapper ];
                postBuild = ''
                  wrapProgram $out/bin/hyprpanel \
                    --prefix GI_TYPELIB_PATH : "${
                      prev.lib.makeSearchPathOutput "lib" "lib/girepository-1.0" [
                        prev.libdbusmenu-gtk3
                        prev.gvfs
                        prev.glib
                        prev.gio-sharp
                        prev.gtk3
                      ]
                    }" \
                    --prefix XDG_DATA_DIRS : "${prev.gvfs}/share:${prev.gtk3}/share" \
                    --prefix GIO_EXTRA_MODULES : "${prev.gvfs}/lib/gio/modules" \
                    --prefix LD_LIBRARY_PATH : "${
                      prev.lib.makeLibraryPath [
                        prev.gvfs
                        prev.glib
                        prev.gtk3
                      ]
                    }" \
                    --prefix PATH : "${
                      prev.lib.makeBinPath [
                        prev.gvfs
                        prev.glib
                        prev.shared-mime-info
                        prev.dbus # Add dbus tools
                        prev.socat # For socket connections
                      ]
                    }"
                '';
              };
            }
          )
          inputs.yazi-plugins.overlays.default
          (final: prev: {
            xdg-desktop-portal-termfilechooser =
              final.callPackage ../modules/home-manager/terminals/core/yazi/xdg-desktop-portal-termfilechooser.nix
                { };
          })
        ];
      }
      # inputs.plasma-manager.homeManagerModules.plasma-manager
    ];
  };

}
