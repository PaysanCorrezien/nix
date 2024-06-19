{ config, pkgs, ... }:

{
  home.packages = [
    pkgs.rustup
    pkgs.rustc
    pkgs.cargo
  ];

  home.sessionVariables = {
    CARGO_HOME = "$HOME/.cargo";
    RUSTUP_HOME = "$HOME/.rustup";
    PATH = [ "$CARGO_HOME/bin" ] ++ config.environment.paths;
  };

  home.activation = {
    initRustup = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if ! command -v rustup &> /dev/null; then
        rustup default stable
      fi
    '';
  };
}

