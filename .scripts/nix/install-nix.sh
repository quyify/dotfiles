#!/bin/bash

if [[ -n "$SPIN" ]]; then
  echo "********************************************************************************"
  echo "This is a SPIN environment.  Sourcing existing Nix install"
  echo "********************************************************************************"

  # Check if the nixpkgs channel is already added
  if ! nix-channel --list | grep -q '^nixpkgs'; then
    # Add the nixpkgs channel
    nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs
    # Update the channels
    nix-channel --update
    echo "nixpkgs channel added and updated."
  else
    echo "nixpkgs channel already exists."
  fi

  return 0
fi

echo "********************************************************************************"
echo "Installing/Updating Nix"
echo "********************************************************************************"

set -e

# install nix (if not already installed)
if [[ ! -f ~/.nix-profile/etc/profile.d/nix.sh ]]; then
  sh <(curl -L https://nixos.org/nix/install) --no-daemon
fi

# Source Nix
source ~/.nix-profile/etc/profile.d/nix.sh

# Use the most update-to-date packages
nix-channel --update && nix-env -u
