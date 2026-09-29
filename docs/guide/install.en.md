# Install everything

You need these tools before the first build. Each row has the command that proves it worked and
real output captured while writing this guide (yours will differ in exact version numbers -- that
is fine, as long as the command does not error).

## Windows

| # | Tool | Install with | Verify | Example output |
|---|------|---------------|--------|-----------------|
| 1 | Git | [git-scm.com](https://git-scm.com/) or `winget install Git.Git` | `git --version` | `git version 2.52.0.windows.1` |
| 2 | GitHub CLI (`gh`) | `winget install GitHub.cli` (needed for `10-release`) | `gh --version` | `gh version 2.90.0` |
| 3 | Chocolatey + Scoop | `3-install-package-manager.bat` | `where choco` | a path under `%ProgramData%\Chocolatey` |
| 4 | .NET SDK (pinned in `global.json`) | `4-install-dotnet-sdk.bat` (per-user, no admin) | `dotnet-env.bat && dotnet --version` | `10.0.401` |
| 5 | Astyle (code formatter) | `4-install-astyle.bat` | `astyle --version` | `Artistic Style Version 3.6.2` |
| 6 | Python 3 | already on most machines, else `choco install python -y` | `py -3.12 --version` | `Python 3.12.6` |
| 7 | coverxygen (Python package) | `4-install-coverxygen.bat` | `py -3.12 -m coverxygen --help` | usage text, no error |
| 8 | lcov (`genhtml`) | `4-install-lcov.bat` | `genhtml --version` | `genhtml: LCOV version 1.15...` |
| 9 | Doxygen + Graphviz, ReportGenerator + DocFX | `6-install-docfx-and-report-tools.bat` | `doxygen --version`, `dot -V`, `dotnet tool restore` | `1.9.7`, `dot - graphviz version 9.0.0`, `Restore was successful.` |

Run them in this order (`3` before `4`/`5`/`6`, `4` before everything that calls `dotnet`):

```batch
3-install-package-manager.bat
4-install-dotnet-sdk.bat
4-install-astyle.bat
4-install-coverxygen.bat
4-install-lcov.bat
6-install-docfx-and-report-tools.bat
```

Each script is idempotent: run it again any time, it only installs what is missing.

> **Why a *pinned per-user* .NET SDK, next to whatever your machine already has?** Many lab/shared
> PCs only have an older SDK installed machine-wide (e.g. only .NET 9 in "Program Files"), and you
> may not have admin rights to change that. `4-install-dotnet-sdk.bat` installs the exact SDK version
> from `global.json` into your own user profile
> (`%LocalAppData%\Microsoft\dotnet`) -- every other script `call`s `dotnet-env.bat` first, which
> quietly prefers that per-user SDK over the machine-wide one. You never need to touch PATH by hand.

## Linux / WSL

Same tools, `apt`-based install, same script numbers with a `.sh` extension:

```bash
chmod +x *.sh   # once, after cloning: git does not preserve the execute bit through a zip download
./3-install-package-manager.sh
./4-install-dotnet-sdk.sh
./4-install-astyle.sh
./4-install-coverxygen.sh
./4-install-lcov.sh
./6-install-docfx-and-report-tools.sh
```

Verify the same way, just without `py -3.12` (WSL uses `python3`):

```bash
. ./dotnet-env.sh && dotnet --version   # 10.0.401
astyle --version                        # Artistic Style Version 3.6.2 (or your distro's version)
python3 -m coverxygen --help
genhtml --version
doxygen --version
```

> **WSL and Google Drive do not mix.** If your clone lives under a Windows Google Drive folder
> (`/mnt/g/My Drive/...`), WSL cannot see it reliably (Google Drive is a virtual/cloud filesystem, not
> a real path, even through the `G:` mount) -- copy the repository into a normal Linux path first
> (e.g. `cp -r "/mnt/g/My Drive/.../vs-net-core-template" ~/vs-net-core-template`) and run every `.sh`
> script from there. See [Troubleshooting](troubleshooting.en.md).

## Optional: an IDE

Visual Studio 2022+ (any edition, "  .NET desktop development" workload) or VS Code with the
[C# Dev Kit](https://marketplace.visualstudio.com/items?itemName=ms-dotnettools.csdevkit) extension
both work; neither is required to run the numbered scripts.

## Next

[Use this template](use-the-template.en.md).
