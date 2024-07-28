{
  description = "Keybswitch flake with auto-imported NixOS module";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
    keybswitch-src = {
      url = "github:PaysanCorrezien/keybswitch";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay, keybswitch-src, ... }:
    let
      overlays = [
        rust-overlay.overlays.default
        (final: prev: {
          rustToolchain = final.rust-bin.stable.latest.default.override {
            extensions = [ "rust-src" ];
          };
        })
      ];
    in flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system overlays; };

        keybswitch = pkgs.rustPlatform.buildRustPackage {
          pname = "keybswitch";
          version = "unstable-${builtins.substring 0 8 keybswitch-src.rev}";
          src = keybswitch-src;

          cargoLock = {
            lockFile = "${keybswitch-src}/Cargo.lock";
            outputHashes = { };
          };

          nativeBuildInputs = [ pkgs.pkg-config ];
          buildInputs = [ pkgs.systemd pkgs.openssl pkgs.libffi ];

          meta = {
            description = "USB Keyboard Detection and Layout Switch";
            homepage = "https://github.com/PaysanCorrezien/keybswitch";
            license = pkgs.lib.licenses.mit;
          };
        };

      in {
        packages.default = keybswitch;

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            rustToolchain
            pkg-config
            systemd
            openssl
            libffi
          ];
        };

        formatter = pkgs.nixpkgs-fmt;
      }) // {
        overlays.default = final: prev: {
          keybswitch = self.packages.${final.system}.default;
        };

        nixosModules.keybswitch = { config, lib, pkgs, ... }:
          let cfg = config.services.keybswitch;
          in {
            options.services.keybswitch = {
              enable = lib.mkEnableOption "Keybswitch service";
            };

            config = lib.mkIf cfg.enable {
              environment.systemPackages =
                [ self.packages.${pkgs.system}.default ];

              systemd.user.services.keybswitch = {
                description =
                  "Keybswitch - USB Keyboard Detection and Layout Switch";
                wantedBy = [ "default.target" ];
                serviceConfig = {
                  ExecStart =
                    "${self.packages.${pkgs.system}.default}/bin/keybswitch";
                  Restart = "always";
                };
              };
            };
          };
      };
}
