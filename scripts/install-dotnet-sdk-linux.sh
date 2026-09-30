#!/bin/bash
# Installs the .NET SDK pinned in global.json, per-user (no sudo needed), using the official
# dotnet-install.sh script. Does NOT touch any distro-packaged dotnet.
set -e
cd "$(dirname "$0")/.."

echo "Installing the .NET SDK pinned in global.json, per-user (no sudo needed)..."
echo

SDK_VERSION=$(grep -oE '"version"[[:space:]]*:[[:space:]]*"[^"]+"' global.json | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+(-[A-Za-z0-9.]+)?')
if [ -z "$SDK_VERSION" ]; then
    echo "[ERROR] Could not read sdk.version from global.json." >&2
    exit 1
fi

echo "Downloading the official installer script from https://dot.net/v1/dotnet-install.sh ..."
curl -sSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh
chmod +x /tmp/dotnet-install.sh

echo "Installing .NET SDK ${SDK_VERSION} into \$HOME/.dotnet ..."
/tmp/dotnet-install.sh --version "$SDK_VERSION"

echo
echo "Installed. The other .sh scripts pick this SDK up automatically via dotnet-env-linux.sh."
echo
"$HOME/.dotnet/dotnet" --version
echo
echo "Done."
