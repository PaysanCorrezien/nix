{ config, pkgs, ... }: {
  programs.bat = {
    enable = true;
    config = { style = "auto,header-filesize"; };
    extraPackages = with pkgs.bat-extras; [
      batdiff
      batgrep
      batman
      batpipe
      batwatch
    ];
  };

  home.shellAliases = {
    cat = "${config.home.profileDirectory}/bin/bat --style=plain";
    man = "${config.home.profileDirectory}/bin/batman";
    diff = "${config.home.profileDirectory}/bin/batdiff";
    watch = "${config.home.profileDirectory}/bin/batwatch";
  };

  programs.zsh.initContent = ''
    export LESSOPEN="|${config.home.profileDirectory}/bin/batpipe %s"
    export LESS="$LESS -R"
    export BATPIPE="color"
    unset LESSCLOSE
  '';
}
