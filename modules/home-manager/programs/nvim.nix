# Unified Neovim configuration (works for desktop, server, and WSL)
{
  config,
  pkgs,
  lib,
  settings,
  ...
}:

let
  isMinimal = settings.minimalNvim or settings.isServer or false;

  nvim-spell-fr-utf8-dictionary = builtins.fetchurl {
    url = "https://ftp.nluug.nl/vim/runtime/spell/fr.utf-8.spl";
    sha256 = "abfb9702b98d887c175ace58f1ab39733dc08d03b674d914f56344ef86e63b61";
  };
  nvim-spell-fr-utf8-suggestions = builtins.fetchurl {
    url = "https://ftp.nluug.nl/vim/runtime/spell/fr.utf-8.sug";
    sha256 = "0294bc32b42c90bbb286a89e23ca3773b7ef50eff1ab523b1513d6a25c6b3f58";
  };

  fullPackages = with pkgs; [
    bash-language-server
    black
    ruff
    cmake-language-server
    clang-tools
    vscode-extensions.vadimcn.vscode-lldb
    docker-compose-language-service
    dockerfile-language-server
    vscode-langservers-extracted
    lua-language-server
    vscode-extensions.davidanson.vscode-markdownlint
    markdownlint-cli2
    marksman
    neocmakelsp
    nil
    nixpkgs-fmt
    nixfmt
    nodePackages.prettier
    nodePackages.typescript-language-server
    pyright
    shellcheck
    shfmt
    sqlfluff
    stylua
    tailwindcss-language-server
    taplo
    yaml-language-server
    ltex-ls
    nodejs
    nodenv
    jdk21
    poppler-utils
    harper
    gnumake
    svelte-language-server
    vtsls
  ];

  minimalPackages = with pkgs; [
    bash-language-server
    taplo
    yaml-language-server
  ];

in
{
  programs.neovim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      nvim-treesitter
      vim-markdown-toc
      nvim-lspconfig
      sqlite-lua
    ];
  };

  programs.zsh.initContent = ''
    export SQL_CLIB_PATH="${pkgs.sqlite.out}/lib/libsqlite3.so"
  '';

  home.packages = if isMinimal then minimalPackages else fullPackages;

  # Spell files
  xdg.configFile."nvim/spell/fr.utf-8.spl".source = nvim-spell-fr-utf8-dictionary;
  xdg.configFile."nvim/spell/fr.utf-8.sug".source = nvim-spell-fr-utf8-suggestions;
}
