# modules/keyboard.nix
{ config, pkgs, ... }:

{
  # Install keyboard-related packages
  environment.systemPackages = with pkgs; [

  wezterm
  git
starship
fzf zoxide bat ripgrep fd 
shell_gpt 
gum glow
btop
pandoc
yazi
tokei
gh
github-copilot-cli
ffmpeg
#TODO : replace this with  real setup
rustup
rustc
cargo

powershell
  wget
ffmpeg
btop
  ];
}

