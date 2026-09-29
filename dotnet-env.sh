#!/bin/bash
# Shared environment setup, sourced (". ./dotnet-env.sh") at the top of the numbered .sh scripts
# that need `dotnet`.
#
# Prefers the per-user .NET SDK installed by 4-install-dotnet-sdk.sh (dotnet-install.sh's default
# install directory, $HOME/.dotnet) over any distro-packaged dotnet on PATH, so the template always
# builds with the SDK pinned in global.json.
if [ -x "$HOME/.dotnet/dotnet" ]; then
    export DOTNET_ROOT="$HOME/.dotnet"
    export PATH="$HOME/.dotnet:$PATH"
fi

export DOTNET_CLI_TELEMETRY_OPTOUT=1
export DOTNET_NOLOGO=1
