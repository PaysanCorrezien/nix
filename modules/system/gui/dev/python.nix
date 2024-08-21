{ lib, config, pkgs, ... }:

let
  myPython = pkgs.python3.withPackages (ps:
    with ps; [
      pillow
      pyperclip
      requests
      pygobject3
      pycairo
      pyyaml
      pyudev
    ]);
in
{
  environment.systemPackages = with pkgs; [
    myPython
    gtk3
    gobject-introspection
    cairo
    gdk-pixbuf
    atk
    pango
    harfbuzz
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
}

