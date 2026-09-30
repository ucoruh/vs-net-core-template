# Releases & private repositories

Your course repository should be **private**, and most students are on the free **GitHub Free**
plan. This page explains what that does and does not let you do, and how `10-release` works around
the one thing it does not: private [GitHub Pages](https://pages.github.com/).

## What works on GitHub Free with a private repository

| Feature | Free (private repo) | Pro / Team / Student Pack |
|---------|----------------------|-----------------------------|
| [Releases](https://docs.github.com/repositories/releasing-projects-on-github) (tags + binary assets, up to 2 GiB/file, up to 1000 assets) | **Yes** -- visible only to collaborators | Yes |
| [GitHub Pages](https://docs.github.com/pages) (a public-ish website URL for the repo) | **No** for a private repo | **Yes** |
| GitHub Actions minutes | 2,000 min/month, 500 MB artifact storage | 3,000 min/month, 1 GB artifact storage |

(Figures per GitHub's own documentation as of this writing; check
[GitHub's pricing page](https://github.com/pricing) for the current numbers.)

Because Pages does not work on a private Free repository, **this template never *requires* Pages**.
`7-build-all` + `9-open-site` show the full site from your own disk (see
[Showing your project without GitHub Pages](showing-without-pages.en.md)), and `10-release` / CI ship
the whole built site inside every release as `<project>-<version>-site.zip` -- that is how your instructor (or anyone
with repo access) views it without Pages. On a **public** repository (this template's own
`ucoruh/vs-net-core-template`, for example), Pages works normally and needs none of this -- see
"The Pages deploy workflow" below.

## The CI workflow and the Pages deploy

`.github/workflows/ci.yml` is one pipeline: Windows and Linux jobs build, test and produce every report and API
doc (`7-build-all-<platform> --no-site`) and upload per-platform artifacts; a macOS job builds the app only; a
`site` job merges both platforms, builds the MkDocs site and the DocFX site, checks the links and uploads the site;
`deploy-pages` publishes it to the `gh-pages` branch on push to `main` (or by hand); `release` runs on a `v*` tag.
It checks `github.event.repository.private` first:

- **Public repository:** Pages deploys normally at `https://<you>.github.io/<your-repo>/`.
- **Private repository:** the Pages step is **skipped** (a `::notice` and the job summary say why and point to
  [Showing your project without GitHub Pages](showing-without-pages.en.md)) *unless* the repository variable
  `PAGES_ON_PRIVATE` is `true` (**Settings -> Secrets and variables -> Actions -> Variables**), which you set once you
  have GitHub Pro (or the Student Developer Pack) *and* turned Pages on under **Settings -> Pages**.

Either way the **release** always attaches the site as `<project>-<version>-site.zip`, and releases are never skipped
on private repositories.

## Get the GitHub Student Developer Pack (optional, gives you Pro)

If you want Pages anyway (e.g. for a portfolio piece later), apply for the
[GitHub Student Developer Pack](https://education.github.com/pack) with your university e-mail.
Approval can take anywhere from minutes to a few days depending on how GitHub verifies your
enrollment (an alumni/student ID photo is sometimes requested) -- do not depend on it arriving
before a deadline. Once approved, GitHub Pro is applied to your account automatically, and you can
enable Pages under the repository's **Settings -> Pages** even while it stays private.

## Add your instructor as a collaborator

Private releases and a private repo's contents are invisible to anyone without access. Add your
instructor so your work can be graded:

**Settings -> Collaborators -> Add people**, add the account named in your course's project guide
(e.g. the instructor's GitHub username), and they must accept the invitation for access to take
effect.

## Install and log in to the GitHub CLI (`gh`)

`10-release` uses [`gh`](https://cli.github.com/), not the web UI, so a release can be published
from a terminal without opening a browser every time.

```bash
# Windows
winget install GitHub.cli
# Linux/WSL
sudo apt-get install gh   # or see https://github.com/cli/cli/blob/trunk/docs/install_linux.md

gh auth login
```

`gh auth login` walks you through browser-based or token-based authentication; choose
`github.com`, HTTPS, and "Login with a web browser" unless you know you need something else.
Verify:

```bash
gh auth status
```

expected output looks like:

```
github.com
  ✓ Logged in to github.com account <your-username> (keyring)
  ✓ Git operations for github.com configured to use https protocol.
  ✓ Token: gho_************************************
```

## Every release asset (the same names locally and on GitHub)

```text
<project>-<version>[-<platform>[-<arch>]]-<content>[-<tool>].<ext>      (version without "v"; from project.env)
```

| Asset | What |
|---|---|
| `calculator-2.1.1-windows-x64-app.zip`, `-linux-x64-app.tar.gz`, `-macos-arm64-app.tar.gz` | the app, self-contained (macOS: CI only) |
| `calculator-2.1.1-<platform>-report-tests.zip` | unit test results (TRX + HTML) |
| `-report-coverage-reportgenerator.zip`, `-report-coverage-lcov.zip` | code coverage, both families |
| `-report-doccoverage-reportgenerator.zip`, `-report-doccoverage-lcov.zip` | documentation coverage, both families |
| `-api-doxygen.zip`, `-api-docfx.zip` | API docs (Doxygen; DocFX is a complete site) |
| `calculator-2.1.1-source.zip`, `-site.zip` | source at the tag; the whole MkDocs site (both platforms) |
| `ASSETS.md`, `SHA256SUMS.txt` | table of every file (platform, content, tool, site link); checksums |

`<platform>` is `windows` or `linux` (native Linux and WSL are both `linux`). `.zip` for Windows binaries and all
HTML; `.tar.gz` for Linux/macOS binaries. Locally, `release/` holds **this platform's** assets plus the neutral ones
and `ASSETS.md` says what is missing; CI builds both platforms.

## Using `10-release`

```batch
10-release-windows.bat --dry-run
10-release-windows.bat
```

On Linux/WSL: `./10-release-linux.sh --dry-run`, etc. The version is `VERSION` in `project.env` (tag `v<VERSION>`):
edit it, commit, then release. `--dry-run` builds everything (`7-build-all`), packs `release/`, then **prints** the
exact `gh release create` command and the asset list instead of running it. The script refuses a real release from a
dirty working tree, and if the release of that tag already exists (for example created by CI) it uploads to it with
`gh release upload --clobber` instead.

## Optional: the CI release

Push a tag (`git tag v2.1.1 && git push origin v2.1.1`) and `ci.yml` builds both platforms plus macOS, then attaches
**every** asset above to the GitHub Release with notes that link the live site and every report page. It uses
Actions minutes (a full run is several minutes on each of three runners); prefer `10-release` locally when you are not
sure how many minutes you have left (Free: 2,000 min/month, private repos).

## Troubleshooting releases

| Symptom | Cause | Fix |
|---------|-------|-----|
| `gh release create` fails with `HTTP 404` | Wrong repo detected, or you are not a collaborator on a private repo you do not own | Run it from inside the cloned repo folder; confirm `gh repo view` shows the right repository |
| `gh release create` fails with `HTTP 403` | Not authenticated, or token missing the `repo` scope | `gh auth login` again; for a fine-grained PAT, make sure it has *Contents: Read and write* on this repo |
| `gh: not logged in` even after `gh auth login` | Logged into a different `gh` host/account than expected | `gh auth status` to see which account is active; `gh auth switch` if you have more than one |
| Upload fails with an asset-too-large message | A single asset over GitHub's 2 GiB limit | Should not happen with this template's assets; if it does, check `publish/` was not accidentally left un-trimmed (e.g. debug symbols) |
| Instructor says they cannot see the release | Not added as a collaborator yet, or invitation not accepted | See "Add your instructor as a collaborator" above |

## Next

If a script itself failed rather than `gh`, see [Troubleshooting](troubleshooting.en.md).
