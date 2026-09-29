#!/bin/bash
set -e
echo "Checking if Astyle is installed..."
if command -v astyle >/dev/null 2>&1; then
    echo "Astyle is already installed."
else
    echo "Installing Astyle..."
    sudo apt-get install -y astyle
fi
echo "Done."
