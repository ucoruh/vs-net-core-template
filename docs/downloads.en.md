# Downloads

Everything the build produces is attached to each GitHub Release, **one to one** with the local
`release/` folder. **[Latest release ↗](https://github.com/ucoruh/vs-net-core-template/releases/latest)**

Asset names follow one pattern, the same in all three templates:

```text
<project>-<version>[-<platform>[-<arch>]]-<content>[-<tool>].<ext>
calculator-2.1.1-windows-x64-app.zip
calculator-2.1.1-linux-x64-app.tar.gz          calculator-2.1.1-macos-arm64-app.tar.gz   (built by CI)
calculator-2.1.1-windows-report-tests.zip      calculator-2.1.1-linux-report-coverage-lcov.zip
calculator-2.1.1-linux-api-doxygen.zip         calculator-2.1.1-windows-api-docfx.zip
calculator-2.1.1-source.zip   calculator-2.1.1-site.zip   ASSETS.md   SHA256SUMS.txt
```

- Platform token: `windows`, `linux` (native Linux **and** WSL), `macos` (CI only, app only). Architecture
  `x64` / `arm64` only appears in binary names.
- `.zip` for Windows binaries and every HTML report; `.tar.gz` for Linux/macOS binaries (keeps the executable bit).
- `project` and `version` come from `project.env`.
- `ASSETS.md` in the release lists every file with its platform, content, tool and site link;
  `SHA256SUMS.txt` lets you verify a download (`sha256sum -c SHA256SUMS.txt`).
- The `site.zip` is this whole site with both platforms' reports. Unzip it and serve it
  (`python -m http.server` inside the folder), or see
  [Showing your project without GitHub Pages](guide/showing-without-pages.en.md).

Old script names and their new names: see the table in the
[README](https://github.com/ucoruh/vs-net-core-template#old-name--new-name).
