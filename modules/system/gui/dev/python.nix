{ lib, config, pkgs, ... }:

let
  cfg = config.settings.isServer;
  myPython = pkgs.python3.withPackages (ps:
    with ps; [
      pillow
      pyperclip
      requests
      pygobject3
      pycairo
      pyyaml
      pyudev
      beautifulsoup4
      openpyxl
      rich
      textual
      evtx
      python-dotenv
      fuzzywuzzy
      yt-dlp
      pyqt5
      google-api-python-client
    ]);
in
{
  config = lib.mkIf (!cfg) {
    environment.systemPackages = with pkgs; [
      myPython
      gtk3
      gobject-introspection
      cairo
      gdk-pixbuf
      atk
      pango
      harfbuzz
      ruff-lsp
    ];
    environment.variables = {
      PYTHONPATH = with pkgs;
        lib.makeSearchPathOutput "lib"
          "python${myPython.pythonVersion}/site-packages" [
          myPython
          python3Packages.pygobject3
          python3Packages.pycairo
        ];
      GI_TYPELIB_PATH = lib.concatStringsSep ":" [
        "${pkgs.gtk3}/lib/girepository-1.0"
        "${pkgs.pango.out}/lib/girepository-1.0"
        "${pkgs.gdk-pixbuf}/lib/girepository-1.0"
        "${pkgs.atk}/lib/girepository-1.0"
        "${pkgs.gobject-introspection}/lib/girepository-1.0"
      ];
      LD_LIBRARY_PATH = with pkgs;
        lib.makeLibraryPath [
          gtk3
          gobject-introspection
          cairo
          gdk-pixbuf
          atk
          pango
          harfbuzz
        ];
    };
    # Add this section to create an alias for your script
    environment.shellAliases = {
      "console" = "python3 ~/repo/pythonautomation/console.py";
       "excel-tool" = "python3 ~/repo/pythonautomation/excel_viewer.py";
       "git-tracker" = "python3 ~/repo/pythonautomation/git_tracker.py";
    };
  };
}
