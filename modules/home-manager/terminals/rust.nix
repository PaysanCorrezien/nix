{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    # rustup
   cargo
   rustfmt
   rust-analyzer
   clippy
   pkg-config
   rustc
   udev
   # clang
   # llvm
  ];

  # Set environment variables for Rust
  home.sessionVariables = {
    CARGO_HOME = "$HOME/.cargo";
    RUSTUP_HOME = "$HOME/.rustup";
    PATH = "$CARGO_HOME/bin:$PATH";
     # Additional configuration to ensure PKG_CONFIG_PATH includes systemd
    PKG_CONFIG_PATH="${pkgs.systemd.dev}/lib/pkgconfig:$PKG_CONFIG_PATH";
  };

  # Ensure Rustup is initialized with the stable toolchain and install rust-analyzer and rustfmt
  home.activation.initRustup = lib.hm.dag.entryAfter ["writeBoundary"] ''
    export CARGO_HOME="$HOME/.cargo"
    export RUSTUP_HOME="$HOME/.rustup"
    export PATH="$CARGO_HOME/bin:$PATH"

    # if ! command -v rustup &> /dev/null; then
    #   ${pkgs.rustup}/bin/rustup default stable
    # fi

    # ${pkgs.rustup}/bin/rustup  component add rust-analyzer
    # ${pkgs.rustup}/bin/rustup component add rustfmt
  '';
}

