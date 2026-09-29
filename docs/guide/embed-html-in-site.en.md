# Showing a report inside your site

Every report this template produces (unit tests, both coverage families, both documentation-coverage
families, Doxygen) gets its own page **inside** the DocFX site that shows the report in a styled,
responsive `<iframe>` — not just a bare link out to a raw HTML file. This page explains how that
works, so you can add a page for a **new** report you introduce yourself (a linter, a static
analyzer, anything else that produces HTML).

## The three pieces

1. **The report itself** — an HTML file (or folder) `7-build-app` generates under `docs/<something>/`
   (e.g. `docs/coveragereport/index.html`). Not written by you.
2. **A resource mapping in `docfx.json`** that copies that folder into the built site, under
   `site/docs/reports/...`. Already present for every report this template ships; you only need to
   add one for a report family you introduce yourself.
3. **A viewer page** — a small Markdown file under `docs/report-pages/`, containing the `<iframe>`,
   the toolbar buttons and the explanatory text. This is what `docs/toc.yml`'s "Reports" section
   links to, not the raw report file.

## Copy-paste snippet

To add a page for a new report (say, a fictional `mytool` HTML report written to
`docs/mytool/index.html`):

**1. Make sure `docfx.json` copies it.** Add a `resource` entry (next to the existing ones) so the
report folder lands under `site/docs/reports/`:

```json
{ "files": [ "mytool/**" ], "src": "docs", "dest": "docs/reports" }
```

**2. Create `docs/report-pages/mytool.md`:**

```markdown
# My Tool Report

One sentence explaining what this report shows and when to look at it.

<div class="report-toolbar">
  <a href="../reports/mytool/index.html" target="_blank" rel="noopener">Open in a new tab ↗</a>
  <a href="../reports/mytool/mytool-report.zip" download>Download (zip)</a>
</div>

<div class="report-frame-wrap">
  <iframe class="report-frame" src="../reports/mytool/index.html" title="My Tool Report" loading="lazy"></iframe>
</div>

<p class="report-fallback">If the frame above stays blank, open it directly:
<a href="../reports/mytool/index.html">docs/reports/mytool/index.html</a>.</p>
```

The `../reports/...` paths are relative to `docs/report-pages/mytool.html` (where this page lands
after the build) — one `../` back out of `report-pages/`, then into `reports/mytool/...`, which is
where step 1's resource mapping put the report. The four CSS classes (`report-toolbar`,
`report-frame-wrap`, `report-frame`, `report-fallback`) come from `templates/rteu/public/main.css`
(a custom DocFX template overlay, see `docfx.json`'s `"template"` array) — a full-height, responsive
frame with `loading="lazy"` so it does not fetch until scrolled into view.

**3. Optional: a "Download (zip)" button.** `7-build-app` zips each report's own folder in place
(step 7 of `7-build-app.bat`/`.sh`) so the zip lands right next to `index.html` and is picked up by
the same resource mapping automatically. Add one more line to your build script's zip step, e.g.:

```batch
powershell -NoProfile -Command "Compress-Archive -Path 'docs\mytool\*' -DestinationPath 'docs\mytool\mytool-report.zip' -Force"
```

If you skip this, just remove the "Download (zip)" line from your page.

**4. Link it from `docs/toc.yml`**, under the existing `Reports` section:

```yaml
- name: Reports
  items:
    - name: My Tool Report
      href: report-pages/mytool.md
```

**5. Add a card to the landing page** (`docs/home.md`, the "Every report, one click away" grid) if
it deserves top-level visibility — copy one of the existing `<a class="rteu-card">` blocks.

## Testing it locally

Run `7-build-app.bat`/`.sh`, then **`9-open-site.bat`/`.sh`** — not a double-click on
`site/index.html`. `9-open-site` serves the built `site/` folder over a small local HTTP server
(`py -3.12 -m http.server` / `python3 -m http.server`) and prints the URL
(`http://localhost:8080/` by default); open that URL in your browser. This step matters: see
"file:// blocks the frame" below.

## Common problems

| Symptom | Cause | Fix |
|---|---|---|
| The frame is blank, but "Open in a new tab" works fine | You opened `site/index.html` directly (`file://...`) instead of through `9-open-site`'s local server. Many browsers refuse to load an `<iframe>` (and DocFX's own search index) from a `file://` page as a security restriction — this has nothing to do with this template specifically. | Use `9-open-site.bat`/`.sh` and open the printed `http://localhost:8080/` URL, or `dotnet docfx serve site`. |
| The frame is blank on GitHub Pages too, with a browser console error mentioning `X-Frame-Options` or `frame-ancestors` | The framed page sent a header refusing to be framed. None of this template's own generated pages do this (they are static HTML with no such header) — this only happens if you point an `<iframe>` at an *external* site instead of a page this repository ships. | Only frame pages this repository itself generates and ships inside `site/`; link out to external tools instead of framing them. |
| A brand-new page 404s inside the frame, even though `docs/<yourreport>/index.html` clearly exists after `7-build-app` | No `resource` mapping for that folder in `docfx.json` — DocFX only copies files it is told to. | Add the `{ "files": [ "<folder>/**" ], "src": "docs", "dest": "docs/reports" }` entry (step 1 above), then rebuild. |
| The frame shows the *wrong* content, or a 404 for a path that looks almost right | An off-by-one in the relative path — `docs/report-pages/*.md` files are one folder level deeper than `docs/*.md` guide pages, so they need `../reports/...`, not `reports/...` (a *guide* page under `docs/guide/` also happens to need `../reports/...`, by coincidence — check the actual folder depth, do not copy-paste blindly). | Count folder levels from the `.md` file's own path to `docs/reports/...`; compare against a working page like `docs/report-pages/unit-tests.md`. |
| `docfx build` prints `warning InvalidFileLink` for a path under `reports/...` | Expected/benign — DocFX's link validator does not track resource files (only content documents). Confirmed in this template's own build; see [Troubleshooting](troubleshooting.en.md). | Ignore it if the file actually resolves once you open the built page; only investigate if the link genuinely does not work. |

## Next

[Which report is which?](reports-explained.en.md) for what each shipped report shows, or
[Troubleshooting](troubleshooting.en.md) if something else failed.
