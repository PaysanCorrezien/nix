{ settings, pkgs, lib, ... }:

# install only if the setings is set to true
let cfg = settings.terminal.extras;
in {
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
      monaspace
    ];
  };
}
