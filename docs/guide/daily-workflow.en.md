# Daily workflow

## The scripts: same number = same job, platform as suffix

Every script exists as `NN-name-windows.bat` and `NN-name-linux.sh` (native Linux and WSL are both `linux`).
Helpers live in `scripts/`. The project name and version come from **`project.env`**.

| Script | What it does | When |
|---|---|---|
| `1-configure-git-hooks` | installs the pre-commit hook (astyle) | once per clone |
| `2-create-gitignore` | regenerates `.gitignore`, keeps this project's own section | rarely |
| `3-install-package-manager` (Windows only) | Chocolatey + Scoop | once per machine |
| `4-install-tools` | .NET SDK, Doxygen, lcov, astyle, dotnet tools, MkDocs Material, coverxygen | once per machine |
| `5-format-code` | astyle over the three C# projects | before a commit (or let the hook do it) |
| `6-build-and-test` | **fast**: build (Debug) + unit tests | after every change |
| `7-build-all` | build, tests + coverage, every report (both families), Doxygen + DocFX, app, site, `release/` | before a push, and for the demo |
| `8-run-app` | runs the sample app (`add 2 3`) | to try it |
| `9-open-site` | serves `site/` on `http://localhost:8080/` and opens it | to look at the site |
| `10-release` | builds and publishes a GitHub Release with `gh` (`--dry-run` first) | when you hand in |
| `11-clean` | deletes every generated folder | when something looks stale |

### Old name → new name

| Old | New |
|---|---|
| `1-pre-commit` | `scripts/hooks/pre-commit` (installed by `1-configure-git-hooks-*`) |
| `2-create-git-ignore.bat/.sh` | `2-create-gitignore-windows.bat` / `-linux.sh` |
| `3-install-package-manager.bat` | `3-install-package-manager-windows.bat` (`.sh` removed: apt is in `4-install-tools-linux.sh`) |
| `4-install-dotnet-sdk`, `4-install-astyle`, `4-install-coverxygen`, `4-install-lcov`, `6-install-docfx-and-report-tools` | all in `4-install-tools-windows.bat` / `-linux.sh` (the SDK and pip parts are helpers in `scripts/`) |
| `5-format-code.bat/.sh` | `5-format-code-windows.bat` / `-linux.sh` |
| *(new)* | `6-build-and-test-windows.bat` / `-linux.sh` |
| `7-build-app.bat/.sh` | `7-build-all-windows.bat` / `-linux.sh` |
| `8-run-app.bat/.sh` | `8-run-app-windows.bat` / `-linux.sh` |
| `9-open-site.bat/.sh` | `9-open-site-windows.bat` / `-linux.sh` |
| `10-release.bat/.sh` | `10-release-windows.bat` / `-linux.sh` |
| *(new)* | `11-clean-windows.bat` / `-linux.sh` |
| `dotnet-env.bat/.sh` | `scripts/dotnet-env-windows.bat` / `-linux.sh` |
| `VERSION` | `VERSION=` in `project.env` |
| `docs/testresults`, `docs/coveragereport`, `docs/doxygen`, … | `reports/<platform>/<kind>-<tool>/` |
| `docfx.json`, `toc.yml` (DocFX was the home page) | `docfx/` (DocFX is now the API reference under `native/`); MkDocs is the main site (`mkdocs.yml`) |
| `pages.yml`, `release.yml` | one pipeline, `ci.yml` |

## A normal day

1. `git checkout -b feature/my-change`
2. Write the test first, then the code, then `6-build-and-test-<platform>` (seconds).
3. Before pushing: `7-build-all-<platform>` and check the coverage report did not drop.
4. `git commit`, `git push`, open a pull request; CI builds Windows, Linux and macOS.

## Where everything lands (all gitignored)

| Folder | Content |
|---|---|
| `build/<platform>-<config>/` | compiler output (`dotnet --artifacts-path`), so Windows and WSL never clash |
| `publish/<platform>-<arch>/` | the app, self-contained |
| `reports/<platform>/<kind>-<tool>/` | `tests-trx`, `coverage-reportgenerator`, `coverage-lcov`, `doccoverage-reportgenerator`, `doccoverage-lcov`, `api-doxygen`, `api-docfx` |
| `site/` | the MkDocs site (the main site): `9-open-site` |
| `site-native/` | the DocFX site (published under `native/`) |
| `release/` | every release asset, same names as on GitHub, plus `ASSETS.md` and `SHA256SUMS.txt` |

Only the small SVG badges under `docs/assets/` are committed (the README and the site embed them).
