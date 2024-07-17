{ pkgs, config, lib, ... }:
let
  nvim-spell-fr-utf8-dictionary = builtins.fetchurl {
    url = "https://ftp.nluug.nl/vim/runtime/spell/fr.utf-8.spl";
    sha256 = "abfb9702b98d887c175ace58f1ab39733dc08d03b674d914f56344ef86e63b61";
  };

  nvim-spell-fr-utf8-suggestions = builtins.fetchurl {
    url = "https://ftp.nluug.nl/vim/runtime/spell/fr.utf-8.sug";
    sha256 = "0294bc32b42c90bbb286a89e23ca3773b7ef50eff1ab523b1513d6a25c6b3f58";
  };
in {
  # home.sessionVariables = {
  #     EDITOR = "nvim";
  #     LD_LIBRARY_PATH = lib.concatStringsSep ":" ([
  #       "${pkgs.sqlite}/lib"
  #     ] ++ lib.optional (config.home.sessionVariables ? LD_LIBRARY_PATH) config.home.sessionVariables.LD_LIBRARY_PATH);
  #   };
  programs.neovim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      nvim-treesitter

      vim-markdown-toc
      nvim-lspconfig
      sqlite-lua
    ];

  };

  #TODO: make this depend on variable to not install all on serv ? 
  # maybe make minimal list for server and add all for desktop ?
  # exemple : taplo yaml-language-server ect and bash-language-server are usefull for server
  home.packages = with pkgs; [
    bash-language-server
    black
    cmake-language-server
    vscode-extensions.vadimcn.vscode-lldb
    # pythonPackages.debugpy
    docker-compose-language-service
    dockerfile-language-server-nodejs
    vscode-extensions.dbaeumer.vscode-eslint
    gitui
    hadolint
    # vscode-extensions.ms-vscode.js-debug
    nodePackages.vscode-json-languageserver-bin
    # json-lsp
    lua-language-server
    vscode-extensions.davidanson.vscode-markdownlint
    markdownlint-cli2
    marksman
    neocmakelsp
    nil
    nixpkgs-fmt
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
    # vtsls
    yaml-language-server
    ltex-ls
    nodejs
    nodenv
    jdk21
    poppler_utils # for neovim pdf preview
  ];
  # Clone the repository using builtins.fetchGit and expose it in the user's home directory
  home.file."repo/nvim-treesitter-powershell".source = builtins.fetchGit {
    url = "https://github.com/PaysanCorrezien/nvim-treesitter-powershell";
    # rev = "master";  # You can specify a specific commit hash here if necessary
  };
  # Ensure the French spell files are downloaded
  home.file."${config.home.homeDirectory}/.config/nvim/spell/fr.utf-8.spl".source =
    nvim-spell-fr-utf8-dictionary;
  home.file."${config.home.homeDirectory}/.config/nvim/spell/fr.utf-8.sug".source =
    nvim-spell-fr-utf8-suggestions;

}

