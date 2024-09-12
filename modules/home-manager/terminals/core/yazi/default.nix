{ lib, pkgs, config, ... }:
let
in {
  home.packages = with pkgs; [ miller ouch xdragon zoxide ueberzugpp ];
  
  programs.yazi = {
    enable = true;
    
    settings = {
      manager = {
        show_hidden = true;
        sort_by = "modified";
        sort_dir_first = true;
        sort_reverse = false;
      };
      preview = {
        max_width = 1920;
        max_height = 1080;
      };
    };
  };
}

