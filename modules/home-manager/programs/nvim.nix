{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.settings;

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
    ruff-lsp
    ruff
    cmake-language-server
    clang-tools
    vscode-extensions.vadimcn.vscode-lldb
    docker-compose-language-service
    dockerfile-language-server-nodejs
    vscode-extensions.dbaeumer.vscode-eslint
    # vscode-extensions.ms-vscode.powershell
    hadolint
    vscode-langservers-extracted
    lua-language-server
    vscode-extensions.davidanson.vscode-markdownlint
    markdownlint-cli2
    marksman
    neocmakelsp
    nil
    nixpkgs-fmt
    nixfmt-rfc-style # new formated , the osed used by lazyvim
    nodePackages.prettier
    nodePackages.typescript-language-server
    pyright
    ruff-lsp
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
    poppler_utils
    harper
    gnumake # for avante build
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
  options = {
    settings = lib.mkOption {
      type = lib.types.submodule {
        options.minimalNvim = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Whether to use a minimal Neovim setup";
        };
      };
    };
  };

  config = {
    programs.neovim = {
      enable = true;
      plugins = with pkgs.vimPlugins; [
        nvim-treesitter
        vim-markdown-toc
        nvim-lspconfig
        sqlite-lua
      ];
    };

    programs.zsh.initExtra = ''
      export SQL_CLIB_PATH="${pkgs.sqlite.out}/lib/libsqlite3.so"
    '';

    home.packages = if cfg.minimalNvim then minimalPackages else fullPackages;

    home.file."${config.home.homeDirectory}/.config/nvim/spell/fr.utf-8.spl".source =
      nvim-spell-fr-utf8-dictionary;
    home.file."${config.home.homeDirectory}/.config/nvim/spell/fr.utf-8.sug".source =
      nvim-spell-fr-utf8-suggestions;
  };
}
