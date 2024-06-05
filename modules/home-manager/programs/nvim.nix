{ pkgs, lib, ... }:

{
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
      nvim-lspconfig
      sqlite-lua
    ];
  };


  # Clone the repository using builtins.fetchGit and expose it in the user's home directory
  home.file."repo/nvim-treesitter-powershell".source = builtins.fetchGit {
    url = "https://github.com/PaysanCorrezien/nvim-treesitter-powershell";
    # rev = "master";  # You can specify a specific commit hash here if necessary
  };
}


