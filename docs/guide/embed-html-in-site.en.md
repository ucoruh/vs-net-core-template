# Showing an HTML report inside your site

The main site is built with **MkDocs Material**. Every report that is **standalone HTML** gets its own page in
the site that shows it in a styled, full-height `<iframe>`; the *Reports* and *API docs* menus list those pages.

## The rule: frame only standalone HTML

| Frame it (standalone HTML made *outside* the site generator) | Link it, never frame it (carries its own site navigation) |
|---|---|
| ReportGenerator, lcov `genhtml`, VSTest/TRX HTML, Doxygen (and JaCoCo, Javadoc, OpenCppCoverage, junit2html in the sibling templates) | **DocFX** pages (and, in the Java template, every Maven site page: Surefire-report, Checkstyle, PMD, CPD, SpotBugs, JXR) |

A DocFX (or Maven site) page has its own header, menu and search. Framing it puts *a site inside a site* — two
menus, two scrollbars, double navigation. So it is built on its own, published under `native/` on the site
(`site-native/` locally) and **linked** from the MkDocs menu so it opens as its own site in a new tab.

Right and wrong:

```html
<!-- RIGHT: a standalone report, framed (docs/reports/windows/coverage-lcov.md) -->
<iframe class="report-frame" src="report/index.html" title="Coverage" loading="lazy"></iframe>

<!-- RIGHT: a site with its own navigation, linked to open on its own (docs/reports/windows/api-docfx.md) -->
<a class="md-button" href="../../../native/windows/index.html" target="_blank" rel="noopener">Open the DocFX site</a>

<!-- WRONG: DocFX framed - the site shows a site -->
<iframe src="../../../native/windows/index.html"></iframe>
```

## How the pieces fit

1. The report is written by `7-build-all-<platform>` to `reports/<platform>/<kind>-<tool>/` (not committed).
2. `scripts/site_tools.py assemble-site` copies it into the built site as
   `site/reports/<platform>/<kind>-<tool>/report/` (and a `report.zip` next to it for the Download button).
3. The page `docs/reports/<platform>/<kind>-<tool>.md` becomes `site/reports/<platform>/<kind>-<tool>/` and frames
   `report/index.html` with a **relative** path — so it works on GitHub Pages under `/<repo>/…` and locally.
4. `mkdocs.yml` lists the page in `nav:` under *Reports*.

## Add your own report page (5 steps)

Example: a report your own tool writes to `reports/windows/mytool/index.html`.

1. **Make the build produce it.** In `7-build-all-windows.bat` (and the `.sh`), write the report to
   `reports\%PLATFORM_TOKEN%\mytool\`.
2. **Register the folder** in `scripts/site_tools.py`, in the `REPORTS` dictionary, e.g.
   `"mytool": ("report-mytool", "My tool report", "What it shows.")`. That gets it zipped into the release
   (`calculator-<version>-windows-report-mytool.zip`) and copied into the site.
3. **Create the page** `docs/reports/windows/mytool.md` (copy `coverage-lcov.md` and change the title, text and the
   two `report/index.html` paths — keep them relative).
4. **Add it to `nav:`** in `mkdocs.yml`:

    ```yaml
    - Reports:
        - Windows:
            - 'My tool': reports/windows/mytool.md
    ```

5. **Test locally:** `7-build-all-windows.bat`, then `9-open-site-windows.bat`, open the page. The build runs a link
   check over the finished site and fails on a broken link in your pages.

## Common problems

| Symptom | Cause | Fix |
|---|---|---|
| The frame is blank but *Open in a new tab* works | You opened `site/index.html` by double-click (`file://`); browsers block frames of `file://` pages | Use `9-open-site-<platform>` (serves `http://localhost:8080/`) |
| The frame shows a "not built on this machine" note | The other platform's report was not built here | Build on that platform, or download the release (CI builds both) |
| 404 inside the frame | Wrong relative path, or the folder was not copied (missing in `REPORTS`) | Page URL is `reports/<platform>/<kind>/`, so the path is `report/…`; check `site/reports/…/report/` exists |
| `check-links` reports a broken link | A link in a page points to something that does not exist | Fix the path it prints (relative to that HTML file) |
| Framed page refuses to load on a real website | The report's server sends `X-Frame-Options: DENY` | Link it in a new tab instead; GitHub Pages does not send it, so this only affects other hosts |
| A DocFX/Maven page inside a frame shows two menus | You framed a site that has its own navigation | Do not frame it; link it (see the rule above) |
