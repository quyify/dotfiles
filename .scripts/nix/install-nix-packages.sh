#!/bin/bash

echo "********************************************************************************"
echo "Installing Nix packages"
echo "********************************************************************************"

if [[ -z "$SPIN" ]]; then
	nix-env -iA nixpkgs.gcc
	nix-env -iA nixpkgs.git
	nix-env -iA nixpkgs.gnumake
	nix-env -iA nixpkgs.neovim
	nix-env -iA nixpkgs.nodePackages.npm
	nix-env -iA nixpkgs.nodejs
	nix-env -iA nixpkgs.ruby_3_3
	nix-env -iA nixpkgs.tmux
	nix-env -iA nixpkgs.unzip
	nix-env -iA nixpkgs.zsh
fi

nix-env -iA nixpkgs.antidote
nix-env -iA nixpkgs.bat
nix-env -iA nixpkgs.cht-sh
nix-env -iA nixpkgs.direnv
nix-env -iA nixpkgs.elixir-ls
nix-env -iA nixpkgs.envsubst
nix-env -iA nixpkgs.fzf
nix-env -iA nixpkgs.lazygit
nix-env -iA nixpkgs.lf
nix-env -iA nixpkgs.libnotify
nix-env -iA nixpkgs.nvimpager
nix-env -iA nixpkgs.ripgrep
nix-env -iA nixpkgs.sourceHighlight
nix-env -iA nixpkgs.stow
nix-env -iA nixpkgs.thefuck
nix-env -iA nixpkgs.tmuxinator
nix-env -iA nixpkgs.xsel
