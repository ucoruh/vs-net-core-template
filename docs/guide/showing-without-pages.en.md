# Showing your project without GitHub Pages

Your repository is **private** and you probably have **GitHub Free**. There, GitHub Pages does not serve a
private repository (it needs GitHub Pro/Team; the free
[GitHub Student Developer Pack](https://education.github.com/pack) includes Pro). That does **not** stop you: the
complete site — every report, both platforms, the API docs — is built and shown **on your own computer**, and
every output is collected in the `release/` folder. Releases *do* work on private repositories.

## Build everything once

=== "Windows"

    ```batch
    7-build-all-windows.bat
    9-open-site-windows.bat
    ```

=== "Linux / WSL"

    ```bash
    ./7-build-all-linux.sh
    ./9-open-site-linux.sh
    ```

`9-open-site` starts a tiny web server and opens **http://localhost:8080/**. Use it instead of double-clicking
`site/index.html`: browsers block frames of `file://` pages, so the report pages would stay blank. Stop the
server with **Ctrl+C**.

Windows and Linux/WSL reports are built and kept separately (they can differ). Your local site fully shows the
platform you built on; the other platform's pages carry a "not built on this machine" note. To have both at the
demo, build on both (Windows, then WSL) — or let CI build both and download the release.

## Demo checklist

Run through this at the project demonstration:

1. **Local site home** — `http://localhost:8080/`: title, badges, report cards.
2. **Each report page**, from the *Reports* menu (Windows / Linux): unit tests, coverage (ReportGenerator and
   lcov), documentation coverage (both). Say what each shows; the *Open in a new tab* button opens the full report.
3. **API docs** — *API docs* menu: Doxygen (in a frame) and DocFX (opens as its own site in a new tab).
4. **The `release/` folder** — show the listing and open `ASSETS.md`: the app archive, every report zip, API docs,
   `…-site.zip`, `…-source.zip`, `SHA256SUMS.txt`.
5. **Run the app from the release archive** — unzip `calculator-<version>-windows-x64-app.zip` (Linux:
   `tar -xzf calculator-<version>-linux-x64-app.tar.gz`) into an empty folder and run `CalculatorApp` there, without
   any .NET installed or repository around it:

    ```batch
    CalculatorApp.exe add 2 3
    ```

6. **Tests** — `6-build-and-test-<platform>` shows the 39 tests passing in seconds.

## The same files in a GitHub Release (works on private repos)

`10-release-<platform>` builds everything and publishes the `release/` folder as a GitHub Release with the GitHub
CLI (`gh`). It first checks that `gh` is logged in and the working tree is clean; try it with `--dry-run` first:

```batch
10-release-windows.bat --dry-run
10-release-windows.bat
```

The version is `VERSION` in `project.env` (edit it, commit, release). Collaborators (your instructor) see the
release and every asset. The site as `…-site.zip`: download, unzip, then in that folder run
`python -m http.server 8080` and open `http://localhost:8080/`.

Details, Free-vs-Pro table and Student Pack steps: [Releases & private repositories](releases-and-private-repos.en.md).
