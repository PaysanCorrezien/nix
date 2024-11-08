{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.settings.isServer;
  myPython = pkgs.python3.withPackages (
    ps: with ps; [
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
      flake8
      ollama
    ]
  );

  scraperPath = /home/dylan/repo/pythonautomation/web_scraper/web_scraper.py;
  webscrapeCmd =
    if builtins.pathExists scraperPath then
      let
        scriptDir = builtins.dirOf scraperPath;
      in
      pkgs.writeShellScriptBin "webscrape" ''
        #!/usr/bin/env bash

        # Try to get git root from current directory
        GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)

        # Build the command with appropriate output directory
        if [ -n "$GIT_ROOT" ]; then
            OUTPUT_ARG="--output $GIT_ROOT/.aider_docs"
        else
            OUTPUT_ARG="--output /tmp/webscraper_output"
        fi

        # Change to the script directory before running
        cd ${scriptDir}

        # Run the script with all arguments plus the output directory
        nix-shell ${scriptDir}/shell.nix --run "python3 ${scraperPath} $@ $OUTPUT_ARG"
      ''
    else
      null;
in
{
  config = lib.mkIf (!cfg) {
    environment.systemPackages =
      with pkgs;
      [
        myPython
        gtk3
        gobject-introspection
        cairo
        gdk-pixbuf
        atk
        pango
        harfbuzz
        ruff-lsp
        devenv
        uv
      ]
      ++ lib.optional (webscrapeCmd != null) webscrapeCmd;
    environment.variables = {
      PYTHONPATH =
        with pkgs;
        lib.makeSearchPathOutput "lib" "python${myPython.pythonVersion}/site-packages" [
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
      LD_LIBRARY_PATH =
        with pkgs;
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
