{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.settings.isServer;

  # Define the VJA package
  vja = pkgs.python3Packages.buildPythonPackage {
    pname = "vja";
    version = "0.1.0"; # Adjust version as needed

    src = pkgs.fetchFromGitLab {
      owner = "ce72";
      repo = "vja";
      rev = "d4cd8f4729f36b671b9945a53178fce2a962d2c8";
      hash = "sha256-KwvPcRWwVdPld0zHmm8UE8hicwF8qLlvHJikb4EJO4Y=";
    };

    # Add any build dependencies the package needs
    buildInputs = with pkgs.python3Packages; [
      # Add build dependencies here if needed
    ];

    # Runtime dependencies from setup.py
    propagatedBuildInputs = with pkgs.python3Packages; [
      click
      click-aliases
      requests
      parsedatetime
      python-dateutil
    ];

    # If the package has a setup.py or pyproject.toml, this should work as is
    # If not, you might need to override the build system
    format = "setuptools";

    # Disable tests if they're not working or if there aren't any
    doCheck = false;
  };

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
      flake8 # for aider
      vja # Add the custom package here
    ]
  );

  scraperPath = /home/dylan/repo/pythonautomation/web_scraper/web_scraper.py;
  webscrapeCmd =
    if builtins.pathExists scraperPath then
      let
        scriptDir = builtins.dirOf scraperPath;
      in
      #TODO: use an environment variable for the output directory
      pkgs.writeShellScriptBin "webscrape" ''
        #!/usr/bin/env bash
        # Try to get git root from current directory
        GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
        # Build the command with appropriate output directory
        if [ -n "$GIT_ROOT" ]; then
            OUTPUT_ARG="--output $GIT_ROOT/.aider_docs"
        else
            OUTPUT_ARG="--output /home/dylan/Documents/Notes/3-Ressources/Docs/"
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
    environment.shellAliases = {
      "console" = "python3 ~/repo/pythonautomation/console.py";
      "excel-tool" = "python3 ~/repo/pythonautomation/excel_viewer.py";
      # "git-tracker" = "python3 ~/repo/pythonautomation/git_tracker.py";
    };
  };
}
