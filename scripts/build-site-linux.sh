#!/bin/bash
# Builds the main site (MkDocs Material) and everything around it. Called by 7-build-all-linux.sh (and
# by the CI merge job after it downloaded both platforms' reports): mkdocs build -> copy
# reports/<platform>/* and the DocFX sites into site/ -> check the links of our own pages -> pack the
# neutral release assets (source zip, site zip, ASSETS.md, SHA256SUMS.txt).
set -e
cd "$(dirname "$0")/.."
. scripts/dotnet-env-linux.sh
. scripts/detect-python-linux.sh
[ -n "$PYTHON_CMD" ] || { echo "[ERROR] No Python with mkdocs and coverxygen found. Run ./4-install-tools-linux.sh." >&2; exit 1; }
rm -rf site
export NO_MKDOCS_2_WARNING=true
"$PYTHON_CMD" -m mkdocs build --site-dir site
"$PYTHON_CMD" scripts/site_tools.py assemble-site --platforms windows,linux
"$PYTHON_CMD" scripts/site_tools.py check-links --site site
"$PYTHON_CMD" scripts/site_tools.py pack-neutral
