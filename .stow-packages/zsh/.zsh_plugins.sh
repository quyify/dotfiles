#!/bin/sh# now, simply add these two lines in your ~/.zshrc

if [[ "$(uname)" == "Darwin" ]]; then
	source $(brew --prefix)/opt/antidote/share/antidote/antidote.zsh
else
	source ~/.nix-profile/share/antidote/antidote.zsh
fi

# initialize plugins statically with ${ZDOTDIR:-~}/.zsh_plugins.txt
antidote load
