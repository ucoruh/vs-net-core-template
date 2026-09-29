#!/bin/bash
# WSL/Linux equivalent of 3-install-package-manager.bat: on Windows we bootstrap Chocolatey/Scoop;
# on WSL/Ubuntu the package manager (apt) is already present, so this just makes sure it is usable
# and up to date (asks for sudo once, like the other install scripts ask for admin once on Windows).
set -e

echo "Checking for apt-get (the package manager used by the rest of the *.sh scripts)..."
if ! command -v apt-get >/dev/null 2>&1; then
    echo "[ERROR] apt-get was not found. These .sh scripts target Debian/Ubuntu-based WSL distros." >&2
    echo "        If you are on a different distro, install doxygen/lcov/astyle/curl with its" >&2
    echo "        native package manager instead, then continue from 4-install-dotnet-sdk.sh." >&2
    exit 1
fi

echo "Refreshing the apt package index (sudo password may be requested once)..."
sudo apt-get update -y

echo "Done."
