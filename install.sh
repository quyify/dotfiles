#!/bin/bash

# go there the directory of this currently 'sourced' script ( quietly )
pushd $(dirname ${BASH_SOURCE:-$0}) >/dev/null

if [[ -n "$SPIN" ]]; then
	# Install/update Homebrew for Spin environments
	source .scripts/brew/install-homebrew.sh

	# Install Homebrew packages (including antidote)
	source .scripts/brew/install-brew-packages.sh
elif [[ "$(uname)" == "Darwin" ]]; then
	# TODO set up homebrew stuff
	echo "Running in Darwin"
else
	# Install/update Nix
	source .scripts/nix/install-nix.sh

	# Nix Packages
	source .scripts/nix/install-nix-packages.sh
fi

# Now that we have stow installed, create symlinks
source .scripts/stow/create-home-dotfile-symlinks.sh

if [[ -n "$SPIN" ]]; then
	# Setup Ruby wrapper for shadowenv
	source .scripts/ruby/setup-ruby-wrapper.sh

	# SPIN settings
	source .scripts/spin/configure-spin.sh

	# Generate zsh config (after Homebrew packages are installed)
	source .scripts/zsh/generate-home-zshrc.sh
elif [[ "$(uname)" == "Darwin" ]]; then
	# Generate zsh config
	source .scripts/zsh/generate-home-zshrc.sh
else
	# Generate zsh config (after Nix packages are installed)
	source .scripts/zsh/generate-home-zshrc.sh
fi

# Tmux Plugins
source .scripts/tmux/install-tmux-plugins.sh

# Neovim plugins
source .scripts/nvim/install-nvim-plugins.sh

# Reload the shell, if logged into the terminal
if [[ -n "$TERM" ]]; then
	exec zsh
fi

# go back to working directory ( quietly )
popd >/dev/null
