#!/bin/bash

echo "********************************************************************************"
echo "Installing Homebrew packages"
echo "********************************************************************************"

# Ensure Homebrew is in PATH
test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Update Homebrew and add required taps
brew update
brew tap jesseduffield/lazygit
brew tap joshmedeski/sesh
brew tap withgraphite/tap

# Function to install a package if it's not already installed
install_if_missing() {
    if ! brew list "$1" &>/dev/null; then
        HOMEBREW_NO_AUTO_UPDATE=1 brew install "$1"
    fi
}

# Additional tools and utilities
install_if_missing antidote
install_if_missing bat
install_if_missing curl
install_if_missing direnv
install_if_missing elixir-ls
install_if_missing gettext
install_if_missing fzf
install_if_missing gum
install_if_missing lazygit
install_if_missing lf
install_if_missing libnotify
install_if_missing nvimpager
install_if_missing ripgrep
install_if_missing sesh
install_if_missing source-highlight
install_if_missing stow
install_if_missing thefuck
install_if_missing tmuxinator
install_if_missing graphite
install_if_missing xsel
install_if_missing zoxide

# Install cht.sh if not already installed
if [[ ! -f /usr/local/bin/cht.sh ]]; then
    curl -s https://cht.sh/:cht.sh | sudo tee /usr/local/bin/cht.sh && sudo chmod +x /usr/local/bin/cht.sh
fi
