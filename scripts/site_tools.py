#!/usr/bin/env python3
"""Cross-platform helpers behind the numbered scripts (same file on Windows, Linux, WSL and CI).

The numbered scripts (`7-build-all-*`, `10-release-*`, ...) call the real tools (dotnet, doxygen,
coverxygen, genhtml, ReportGenerator, DocFX, MkDocs). This file only does the file shuffling that
would otherwise be written twice (once in .bat, once in .sh) -- zipping, naming, checksums, copying
reports into the site and checking the site's links. Plain standard library, Python 3.8+.

Commands (all read project.env for PROJECT_NAME and VERSION):

  pack-platform --platform windows|linux|macos [--arch x64] [--app-only]
        release/<project>-<version>-<platform>[-<arch>]-<content>[-<tool>].<ext> for one platform
  assemble-site [--site site] [--platforms windows,linux]
        copy reports/<platform>/* into site/reports/<platform>/<kind>-<tool>/report/ (and the
        DocFX sites into site/native/<platform>/), with a placeholder for a missing platform
  pack-neutral [--site-url URL]
        source zip, site zip, ASSETS.md, SHA256SUMS.txt in release/ and build/release-notes.md
  check-links [--site site]
        walk the built site; exit 1 if one of OUR OWN pages links to something that does not exist
"""
import argparse
import hashlib
import html
import os
import re
import shutil
import subprocess
import sys
import tarfile
import zipfile
from html.parser import HTMLParser
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PLATFORMS = ("windows", "linux")

# folder under reports/<platform>/ -> (release asset content, title, one-line description, needs iframe)
REPORTS = {
    "tests-trx": ("report-tests", "Unit test results (native: TRX + VSTest HTML)",
                  "Pass/fail list of every xUnit test, from the .NET test platform's own HTML logger and TRX file."),
    "coverage-reportgenerator": ("report-coverage-reportgenerator", "Code coverage - ReportGenerator",
                                 "Per-file, per-line coverage with history and trend graphs (cobertura input)."),
    "coverage-lcov": ("report-coverage-lcov", "Code coverage - lcov / genhtml (native)",
                      "The same coverage numbers rendered by lcov's classic genhtml directory-tree view."),
    "doccoverage-reportgenerator": ("report-doccoverage-reportgenerator", "Documentation coverage - ReportGenerator",
                                    "How much of the public API carries an XML doc comment (coverxygen lcov input)."),
    "doccoverage-lcov": ("report-doccoverage-lcov", "Documentation coverage - lcov / genhtml (native)",
                         "The same documentation-coverage data rendered by genhtml."),
    "api-doxygen": ("api-doxygen", "API docs - Doxygen",
                    "Ecosystem-neutral API reference (the same tool the C/C++ and Java templates use)."),
    "api-docfx": ("api-docfx", "API docs - DocFX (C# native)",
                  "C#-native API reference generated from the XML doc comments. It is a complete site of its own."),
}

CONTENT_TEXT = {
    "app": ("Application", "the sample console app (self-contained, no .NET install needed)", "dotnet publish"),
    "report-tests": ("Unit test results", "TRX + VSTest HTML", "dotnet test"),
    "report-coverage-reportgenerator": ("Code coverage", "HTML + badges + history", "ReportGenerator"),
    "report-coverage-lcov": ("Code coverage", "HTML (lcov tree view)", "lcov / genhtml"),
    "report-doccoverage-reportgenerator": ("Documentation coverage", "HTML", "coverxygen + ReportGenerator"),
    "report-doccoverage-lcov": ("Documentation coverage", "HTML (lcov tree view)", "coverxygen + lcov / genhtml"),
    "api-doxygen": ("API docs", "Doxygen HTML", "Doxygen"),
    "api-docfx": ("API docs", "DocFX site (own navigation)", "DocFX"),
    "source": ("Source code", "git archive of the tagged commit", "git"),
    "site": ("Site", "the whole MkDocs site, both platforms' reports inside", "MkDocs Material"),
}


def load_env():
    env = {}
    p = ROOT / "project.env"
    for line in p.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        k, v = line.split("=", 1)
        env[k.strip()] = v.strip()
    for key in ("PROJECT_NAME", "VERSION"):
        if key not in env:
            sys.exit("[ERROR] %s missing in project.env" % key)
    return env


def prefix(env):
    return "%s-%s" % (env["PROJECT_NAME"], env["VERSION"])


def zip_dir(src, dest, exclude_names=()):
    dest.parent.mkdir(parents=True, exist_ok=True)
    if dest.exists():
        dest.unlink()
    with zipfile.ZipFile(str(dest), "w", zipfile.ZIP_DEFLATED) as z:
        for f in sorted(Path(src).rglob("*")):
            if f.is_file() and f.name not in exclude_names and f.resolve() != dest.resolve():
                z.write(str(f), f.relative_to(src).as_posix())


def tar_dir(src, dest):
    dest.parent.mkdir(parents=True, exist_ok=True)
    if dest.exists():
        dest.unlink()
    with tarfile.open(str(dest), "w:gz") as t:
        for f in sorted(Path(src).rglob("*")):
            if f.is_file() or f.is_symlink():
                t.add(str(f), arcname=f.relative_to(src).as_posix(), recursive=False)


def has_content(d):
    return d.is_dir() and any(p.is_file() for p in d.rglob("*"))


# ----------------------------------------------------------------------------------------------
def cmd_pack_platform(a):
    env = load_env()
    rel = ROOT / "release"
    rel.mkdir(exist_ok=True)
    plat, arch = a.platform, a.arch
    # drop stale assets of this platform (any earlier version) so a version bump does not pile up
    for f in rel.glob("%s-*-%s-*" % (env["PROJECT_NAME"], plat)):
        f.unlink()
    made = []
    app_dir = ROOT / "publish" / ("%s-%s" % (plat, arch))
    if has_content(app_dir):
        if plat == "windows":
            dest = rel / ("%s-%s-%s-app.zip" % (prefix(env), plat, arch))
            zip_dir(app_dir, dest)
        else:
            dest = rel / ("%s-%s-%s-app.tar.gz" % (prefix(env), plat, arch))
            tar_dir(app_dir, dest)
        made.append(dest)
    else:
        print("  [WARN] %s not found -- no app archive for %s" % (app_dir, plat))
    if not a.app_only:
        for folder, (asset, _t, _d) in REPORTS.items():
            src = ROOT / "reports" / plat / folder
            if has_content(src):
                dest = rel / ("%s-%s-%s.zip" % (prefix(env), plat, asset))
                zip_dir(src, dest)
                made.append(dest)
            else:
                print("  [WARN] reports/%s/%s not found -- no %s asset" % (plat, folder, asset))
    for m in made:
        print("  %s  (%d KB)" % (m.relative_to(ROOT).as_posix(), m.stat().st_size // 1024))


# ----------------------------------------------------------------------------------------------
PLACEHOLDER = """<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Not built on this machine</title>
<style>body{font-family:system-ui,sans-serif;max-width:40rem;margin:3rem auto;padding:0 1rem;line-height:1.5}
code{background:#eee;padding:.1em .3em;border-radius:3px}@media(prefers-color-scheme:dark){body{background:#1b1b1f;color:#ddd}code{background:#333}}</style></head>
<body><h2>%(what)s &mdash; not built on this machine</h2>
<p>Reports are produced <strong>separately for Windows and for Linux/WSL</strong> because they can differ.
This build was made on another platform, so the <strong>%(plat)s</strong> copy is not in this site.</p>
<p>Run <code>%(script)s</code> on a %(plat)s machine, or use the release from GitHub, where CI builds both platforms
(asset <code>%(asset)s</code>).</p></body></html>
"""


def cmd_assemble_site(a):
    env = load_env()
    site = ROOT / a.site
    if not site.is_dir():
        sys.exit("[ERROR] %s does not exist -- run mkdocs build first" % site)
    native_local = ROOT / "site-native"
    if native_local.exists():
        shutil.rmtree(str(native_local))
    for plat in a.platforms.split(","):
        script = "7-build-all-windows.bat" if plat == "windows" else "./7-build-all-linux.sh"
        for folder, (asset, _t, _d) in REPORTS.items():
            src = ROOT / "reports" / plat / folder
            page = site / "reports" / plat / folder
            report = page / "report"
            asset_name = "%s-%s-%s.zip" % (prefix(env), plat, asset)
            if has_content(src) and folder != "api-docfx":
                shutil.copytree(str(src), str(report))
                z = ROOT / "release" / asset_name
                if z.exists():
                    shutil.copyfile(str(z), str(page / "report.zip"))
                else:
                    zip_dir(src, page / "report.zip")
            elif folder == "api-docfx":
                # DocFX is a complete site with its own navigation: it goes under native/, never in an iframe
                nat = site / "native" / plat
                if has_content(src):
                    shutil.copytree(str(src), str(nat))
                    shutil.copytree(str(src), str(native_local / plat))
                else:
                    nat.mkdir(parents=True, exist_ok=True)
                    (nat / "index.html").write_text(PLACEHOLDER % dict(what="DocFX API reference", plat=plat, script=script, asset=asset_name), encoding="utf-8")
                z = ROOT / "release" / asset_name
                page.mkdir(parents=True, exist_ok=True)
                if z.exists():
                    shutil.copyfile(str(z), str(page / "report.zip"))
                else:
                    with zipfile.ZipFile(str(page / "report.zip"), "w") as zz:
                        zz.writestr("README.txt", "Not built on this machine. Run %s.\n" % script)
            else:
                report.mkdir(parents=True, exist_ok=True)
                text = PLACEHOLDER % dict(what=_t, plat=plat, script=script, asset=asset_name)
                for entry in ("index.html", "test-results.html"):   # every entry page the report pages frame
                    (report / entry).write_text(text, encoding="utf-8")
                with zipfile.ZipFile(str(page / "report.zip"), "w") as zz:
                    zz.writestr("README.txt", "Not built on this machine. Run %s.\n" % script)
    print("  reports and native sites copied into %s/" % a.site)


# ----------------------------------------------------------------------------------------------
ASSET_RE = None


def site_url_from_git():
    try:
        out = subprocess.check_output(["git", "config", "--get", "remote.origin.url"], cwd=str(ROOT), stderr=subprocess.DEVNULL).decode().strip()
    except Exception:
        return ""
    m = re.match(r"^(?:https://github\.com/|git@github\.com:)([^/]+)/(.+?)(?:\.git)?$", out)
    return "https://%s.github.io/%s/" % (m.group(1), m.group(2)) if m else ""


def sha256(p):
    h = hashlib.sha256()
    with open(str(p), "rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def site_link(base, plat, content):
    for folder, (asset, _t, _d) in REPORTS.items():
        if asset == content and plat:
            if folder == "api-docfx":
                return "%snative/%s/" % (base, plat)
            return "%sreports/%s/%s/" % (base, plat, folder)
    if content == "app":
        return "%sdownloads/" % base
    return base


def cmd_pack_neutral(a):
    env = load_env()
    name, ver = env["PROJECT_NAME"], env["VERSION"]
    pre = prefix(env)
    rel = ROOT / "release"
    rel.mkdir(exist_ok=True)
    base = a.site_url or site_url_from_git()
    base_disp = base or "(enable GitHub Pages, or unzip the site archive and serve it -- see docs/guide/showing-without-pages.en.md)"
    # neutral assets
    for f in rel.glob("%s-*-source.zip" % name):
        f.unlink()
    for f in rel.glob("%s-*-site.zip" % name):
        f.unlink()
    src_zip = rel / ("%s-source.zip" % pre)
    subprocess.check_call(["git", "archive", "--format=zip", "--prefix=%s/" % pre, "-o", str(src_zip), "HEAD"], cwd=str(ROOT))
    site = ROOT / "site"
    if not (site / "index.html").exists():
        sys.exit("[ERROR] site/index.html not found -- build the site first")
    zip_dir(site, rel / ("%s-site.zip" % pre))

    pat = re.compile(r"^%s-%s(?:-(windows|linux|macos))?(?:-(x64|arm64))?-(.+?)\.(zip|tar\.gz)$" % (re.escape(name), re.escape(ver)))
    rows = []
    present = {"windows": False, "linux": False}
    for f in sorted(rel.iterdir()):
        m = pat.match(f.name)
        if not m:
            continue
        plat, arch, content, _ext = m.groups()
        if plat in present:
            present[plat] = True
        title, what, tool = CONTENT_TEXT.get(content, (content, "", ""))
        if content == "app" and plat and arch:
            what = "%s -- %s %s" % (what, plat, arch)
        if content == "api-docfx":
            what = what
        rows.append((f.name, plat or "any", title, what, tool, site_link(base, plat, content) if base else "-"))
    md = ["# Release assets -- %s %s" % (name, ver), ""]
    md.append("Everything in this folder is also attached to the GitHub Release of the same version, one to one. "
              "Site: %s" % base_disp)
    md.append("")
    md.append("| File | Platform | Content | What is inside | Tool | Site link |")
    md.append("|---|---|---|---|---|---|")
    for r in rows:
        md.append("| `%s` | %s | %s | %s | %s | %s |" % r)
    md.append("| `SHA256SUMS.txt` | any | Checksums | SHA-256 of every file above (`sha256sum -c SHA256SUMS.txt`) | sha256 | - |")
    md.append("")
    missing = [p for p, ok in present.items() if not ok]
    if missing:
        md.append("**Not in this folder:** %s assets. Reports and binaries are built separately per platform "
                  "(Windows and Linux/WSL can differ). This folder was produced on one platform; CI builds both, so the "
                  "GitHub Release has them all. To get the rest locally, run `7-build-all-<platform>` on that platform." % " and ".join(missing))
        md.append("")
    md.append("The macOS app archive is built by CI only. See `docs/guide/reports-explained.en.md` (\"Which report is which?\").")
    (rel / "ASSETS.md").write_text("\n".join(md) + "\n", encoding="utf-8")

    sums = []
    for f in sorted(rel.iterdir()):
        if f.is_file() and f.name != "SHA256SUMS.txt":
            sums.append("%s  %s" % (sha256(f), f.name))
    (rel / "SHA256SUMS.txt").write_text("\n".join(sums) + "\n", encoding="utf-8")

    # release notes (not an asset): live site + every report page + the asset table
    notes = ["# %s v%s" % (name, ver), "", "## Live site", ""]
    if base:
        notes.append("- Home: %s" % base)
        notes.append("- Downloads: %sdownloads/" % base)
        for plat in PLATFORMS:
            notes.append("")
            notes.append("**%s**" % plat.capitalize())
            for folder, (asset, title, _d) in REPORTS.items():
                if folder == "api-docfx":
                    notes.append("- [%s](%snative/%s/) (opens as its own site)" % (title, base, plat))
                else:
                    notes.append("- [%s](%sreports/%s/%s/)" % (title, base, plat, folder))
        notes.append("- Guides: [English](%sguide/install.en/) / [Turkce](%sguide/install.tr/)" % (base, base))
    else:
        notes.append("Pages is not enabled for this repository: download `%s-site.zip`, unzip it and serve it (see the guide "
                     "'Showing your project without GitHub Pages')." % pre)
    notes += ["", "## Assets", ""] + md[3:]
    notes += ["", "## Commits", ""]
    try:
        prev = subprocess.check_output(["git", "describe", "--tags", "--abbrev=0", "HEAD^"], cwd=str(ROOT), stderr=subprocess.DEVNULL).decode().strip()
        log = subprocess.check_output(["git", "log", "%s..HEAD" % prev, "--oneline"], cwd=str(ROOT)).decode()
    except Exception:
        log = subprocess.check_output(["git", "log", "-n", "20", "--oneline"], cwd=str(ROOT)).decode()
    notes += ["- " + l for l in log.splitlines()]
    (ROOT / "build").mkdir(exist_ok=True)
    (ROOT / "build" / "release-notes.md").write_text("\n".join(notes) + "\n", encoding="utf-8")
    print("  release/ now holds %d files (ASSETS.md and SHA256SUMS.txt included)" % len(list(rel.iterdir())))


# ----------------------------------------------------------------------------------------------
class LinkCollector(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.links = []

    def handle_starttag(self, tag, attrs):
        d = dict(attrs)
        if tag in ("a", "link") and d.get("href"):
            self.links.append(d["href"])
        elif tag in ("img", "script", "iframe", "source") and d.get("src"):
            self.links.append(d["src"])
        elif tag == "object" and d.get("data"):
            self.links.append(d["data"])


def cmd_check_links(a):
    site = (ROOT / a.site).resolve()
    if not site.is_dir():
        sys.exit("[ERROR] %s not found" % site)
    broken, checked, pages = [], 0, 0
    for f in sorted(site.rglob("*.html")):
        rel = f.relative_to(site).as_posix()
        parts = rel.split("/")
        # only OUR pages are hard-checked: skip the contents of embedded standalone reports and the native sites
        if "report" in parts[:-1] and parts[0] == "reports":
            continue
        if parts[0] == "native" or rel == "404.html":
            continue
        pages += 1
        c = LinkCollector()
        c.feed(f.read_text(encoding="utf-8", errors="replace"))
        for link in c.links:
            l = html.unescape(link).strip()
            if not l or l.startswith(("#", "http:", "https:", "mailto:", "javascript:", "data:", "tel:", "//")):
                continue
            l = l.split("#", 1)[0].split("?", 1)[0]
            if not l:
                continue
            target = (site / l.lstrip("/")) if l.startswith("/") else (f.parent / l)
            try:
                target = Path(os.path.normpath(str(target)))
            except Exception:
                pass
            checked += 1
            if target.is_dir():
                target = target / "index.html"
            if not target.exists():
                broken.append((rel, link))
    print("  checked %d links in %d pages of our own site" % (checked, pages))
    if broken:
        print("[ERROR] %d broken link(s):" % len(broken))
        for rel, link in broken[:80]:
            print("   %s -> %s" % (rel, link))
        sys.exit(1)
    print("  no broken links")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("pack-platform")
    p.add_argument("--platform", required=True, choices=("windows", "linux", "macos"))
    p.add_argument("--arch", default="x64")
    p.add_argument("--app-only", action="store_true")
    p.set_defaults(fn=cmd_pack_platform)
    p = sub.add_parser("assemble-site")
    p.add_argument("--site", default="site")
    p.add_argument("--platforms", default="windows,linux")
    p.set_defaults(fn=cmd_assemble_site)
    p = sub.add_parser("pack-neutral")
    p.add_argument("--site-url", default="")
    p.set_defaults(fn=cmd_pack_neutral)
    p = sub.add_parser("check-links")
    p.add_argument("--site", default="site")
    p.set_defaults(fn=cmd_check_links)
    a = ap.parse_args()
    a.fn(a)


if __name__ == "__main__":
    main()
