# Install everything

You need these tools before the first build. **One script does it all** — `4-install-tools-windows.bat`
or `./4-install-tools-linux.sh` — and every tool has a command that proves it worked. (Numbers in your
output will differ slightly; that is fine as long as the command does not fail.)

## Windows

1. Install **Git** ([git-scm.com](https://git-scm.com/) or `winget install Git.Git`) and the **GitHub CLI**
   (`winget install GitHub.cli`, needed only for `10-release`). Open a new terminal afterwards.
2. Install the package manager once (run the terminal **as Administrator**):

    ```batch
    3-install-package-manager-windows.bat
    ```

3. Install everything else (no admin needed for the .NET SDK; Chocolatey installs may ask for it):

    ```batch
    4-install-tools-windows.bat
    ```

    It installs: the .NET SDK pinned in `global.json` (per user), Doxygen, Graphviz, lcov (`genhtml`) with a
    Windows-native Perl, astyle, the local dotnet tools (ReportGenerator, DocFX) and the Python tools from
    `requirements.txt` (MkDocs Material, coverxygen). It is safe to re-run: it only installs what is missing.

| Tool | Verify | Example output |
|------|--------|-----------------|
| Git | `git --version` | `git version 2.52.0.windows.1` |
| .NET SDK | `scripts\dotnet-env-windows.bat && dotnet --version` | `10.0.401` |
| Python + MkDocs | `py -3.12 -m mkdocs --version` | `mkdocs, version 1.6.1 ...` |
| coverxygen | `py -3.12 -m coverxygen --help` | usage text, no error |
| Doxygen | `doxygen --version` | `1.9.x` or newer |
| lcov | `genhtml --version` | `genhtml: LCOV version 1.x/2.x` |
| ReportGenerator, DocFX | `dotnet tool restore` | `Restore was successful.` |
| astyle | `astyle --version` | `Artistic Style Version 3.x` |

> **Why a pinned per-user .NET SDK?** Lab PCs often have only an older SDK machine-wide, and you may not have
> admin rights. `4-install-tools-windows.bat` installs the exact SDK from `global.json` into
> `%LocalAppData%\Microsoft\dotnet`; every script loads `scripts\dotnet-env-windows.bat` first, which prefers it.
> You never edit PATH by hand.

## Linux / WSL

WSL **is** Linux here: the same `*-linux.sh` scripts, Linux binaries, `linux` in every file name.

```bash
chmod +x *.sh scripts/*.sh        # once after cloning (a zip download loses the execute bit)
./4-install-tools-linux.sh        # apt packages (asks for sudo once), .NET SDK per user, dotnet tools, pip tools
```

Verify:

```bash
. scripts/dotnet-env-linux.sh && dotnet --version   # 10.0.401
python3 -m mkdocs --version
python3 -m coverxygen --help
genhtml --version
doxygen --version
```

> **WSL and Google Drive do not mix.** Clone into a normal Linux path (`~/work/...`), not under
> `/mnt/g/My Drive/...`. See [Troubleshooting](troubleshooting.en.md).

!!! note "WSL has its own `gh` login"
    `gh` and git credentials on Windows are **not** shared with WSL. To use a private repository in WSL, run
    `gh auth login` and then `gh auth setup-git` inside Ubuntu, and check with `gh auth status`; otherwise
    `git clone` hangs asking for a password.

## Optional: an IDE

Visual Studio 2022+ (".NET desktop development" workload) or VS Code with the C# Dev Kit. Neither is needed to
run the scripts.

## Next

[Use this template](use-the-template.en.md).
