{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    rustup
 #   rustc
#    cargo
  ];

  # Set environment variables for Rust
  home.sessionVariables = {
    CARGO_HOME = "$HOME/.cargo";
    RUSTUP_HOME = "$HOME/.rustup";
    PATH = "$CARGO_HOME/bin:$PATH";
  };

  # Ensure Rustup is initialized with the stable toolchain
  home.activation.initRustup = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if ! command -v rustup &> /dev/null; then
      export CARGO_HOME="$HOME/.cargo"
      export RUSTUP_HOME="$HOME/.rustup"
      export PATH="$CARGO_HOME/bin:$PATH"
      ${pkgs.rustup}/bin/rustup default stable
    fi
  '';
}

