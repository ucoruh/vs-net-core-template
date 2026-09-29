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
`9-open-site` serves and opens the site from your own disk (over a small local HTTP server -- see
[Showing a report inside your site](embed-html-in-site.en.md)), and `10-release`/`release.yml` ship
the whole built site inside every release as `site.zip` -- that is how your instructor (or anyone
with repo access) views it without Pages. On a **public** repository (this template's own
`ucoruh/vs-net-core-template`, for example), Pages works normally and needs none of this -- see
"The Pages deploy workflow" below.

## The Pages deploy workflow

`.github/workflows/pages.yml` rebuilds the full site and publishes it to the `gh-pages` branch on
every push to `main` (and by hand, `workflow_dispatch`). It checks
`github.event.repository.private` first:

- **Public repository:** deploys normally. The live site ends up at
  `https://<you>.github.io/<your-repo>/`.
- **Private repository:** the deploy step is **skipped**, with an explanation both as a `::notice`
  annotation on the run and in the run's job summary -- *unless* the repository variable
  `PAGES_ON_PRIVATE` is set to `true`. Set it under **Settings -> Secrets and variables -> Actions ->
  Variables** once you have GitHub Pro (or the Student Developer Pack) *and* have turned Pages on
  under **Settings -> Pages** -- then the next push deploys normally.

Either way, `release.yml` (below) always attaches `site.zip`, so the site reaches your instructor
regardless of whether Pages is enabled.

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

## Using `10-release`

```batch
10-release.bat --dry-run
10-release.bat v1.0.0 --dry-run
10-release.bat v1.0.0
```

on Linux/WSL: `./10-release.sh --dry-run`, etc. `--dry-run` builds and packages everything -- runs
`7-build-app`, publishes self-contained binaries for Linux/macOS/Windows, packs every report (both
families -- see [Which report is which?](reports-explained.en.md)), the Doxygen output and the
whole DocFX site as `release/site.zip` -- then **prints** the exact `gh release create` command and
the full asset list instead of running it. Nothing is published. Drop `--dry-run` once you are
happy with what it printed.

Without an explicit version argument, the script reads the `VERSION` file (a single line like
`0.1.0`) at the repository root; bump that file for your next release. The script refuses to
publish a real release from a dirty working tree (uncommitted changes) -- a release should always
correspond to one exact, committed state of the code (`--dry-run` skips this check so you can
rehearse packaging mid-work).

What lands in `release/site.zip`: the entire built site, self-contained -- unzip it anywhere and
open `index.html`; every report and API reference link inside it is a relative link that works
without a web server.

## Optional: the Actions release workflow

`.github/workflows/release.yml` is an alternative way to do the same publish from CI instead of your
own machine, triggered by pushing a `v*` tag or by hand (`workflow_dispatch`) -- useful if you would
rather not run `10-release` locally, at the cost of Actions minutes (a full build + publish +
package run typically costs a few minutes of your monthly quota; the day-to-day `ci.yml` workflow
does **not** run this on every push, only on request/tag, precisely to not eat into that budget).
It packages the same asset set as `10-release` (see the table above) plus a `source.zip` source
archive, and writes release notes that link to the live site and list every asset. On a private
repository it adds a `::notice`/step-summary reminder to add your instructor as a collaborator (see
above) -- releases themselves are **not** skipped on private (unlike the Pages deploy). Prefer
`10-release` locally when you are not sure how many minutes you have left.

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
