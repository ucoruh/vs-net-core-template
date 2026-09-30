#!/bin/bash
# Sourced (". scripts/dotnet-env-linux.sh") at the top of every script that needs `dotnet`: loads
# project.env, then prefers the per-user .NET SDK installed by 4-install-tools-linux.sh
# ($HOME/.dotnet) over any distro-packaged dotnet, so the template builds with the SDK pinned in
# global.json.
. "$(dirname "${BASH_SOURCE[0]}")/load-project-env-linux.sh"
if [ -x "$HOME/.dotnet/dotnet" ]; then
    export DOTNET_ROOT="$HOME/.dotnet"
    export PATH="$HOME/.dotnet:$PATH"
fi
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export DOTNET_NOLOGO=1
