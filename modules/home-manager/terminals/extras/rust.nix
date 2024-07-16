{ settings, pkgs, lib, ... }:

let cfg = settings.terminal.extras;
in {
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      cargo
      rustfmt
      rust-analyzer
      clippy
      pkg-config
      rustc
      udev
    ];

    home.sessionVariables = {
      CARGO_HOME = "$HOME/.cargo";
      RUSTUP_HOME = "$HOME/.rustup";
      PATH = "$CARGO_HOME/bin:$PATH";
      PKG_CONFIG_PATH = "${pkgs.systemd.dev}/lib/pkgconfig:$PKG_CONFIG_PATH";
    };

    home.activation.initRustup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      export CARGO_HOME="$HOME/.cargo"
      export RUSTUP_HOME="$HOME/.rustup"
      export PATH="$CARGO_HOME/bin:$PATH"
    '';
  };
}
