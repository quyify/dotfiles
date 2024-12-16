#!/bin/bash

echo "********************************************************************************"
echo "Setting up Ruby wrapper for shadowenv"
echo "********************************************************************************"

if [[ -n "$SPIN" ]]; then
    # Get the directory of this script
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # Create the wrapper script from template
    sudo cp "$SCRIPT_DIR/ruby_wrapper.template" /usr/local/bin/ruby_Shopify_shopify

    # Make the wrapper script executable
    sudo chmod +x /usr/local/bin/ruby_Shopify_shopify

    echo "Ruby wrapper script created at /usr/local/bin/ruby_Shopify_shopify"
fi
