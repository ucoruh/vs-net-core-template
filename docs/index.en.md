---
title: Home
hide:
  - toc
---

<div class="rteu-hero" markdown>

# Calculator — a complete .NET course-project template

<p class="lead">A C# / .NET solution you start your term project from: a class library, a thin console app,
xUnit tests, and <strong>every report in two families side by side</strong> (ReportGenerator and the older, native
tools) — built separately on <strong>Windows</strong> and <strong>Linux</strong>, with Doxygen and DocFX API docs, one
site, and one-command local and CI/CD release packaging.</p>

<div class="rteu-badges" markdown>

[![CI](https://github.com/ucoruh/vs-net-core-template/actions/workflows/ci.yml/badge.svg)](https://github.com/ucoruh/vs-net-core-template/actions/workflows/ci.yml)
[![GitHub release](https://badgen.net/github/release/ucoruh/vs-net-core-template)](https://github.com/ucoruh/vs-net-core-template/releases/latest)
[![License: MIT](https://badgen.net/github/license/ucoruh/vs-net-core-template)](https://github.com/ucoruh/vs-net-core-template/blob/main/LICENSE)
![Combined coverage](assets/badge_combined.svg)
![Branch coverage](assets/badge_branchcoverage.svg)
![Line coverage](assets/badge_linecoverage.svg)
![Method coverage](assets/badge_methodcoverage.svg)
![Doc coverage](assets/badge_doccoverage.svg)

</div>

<a class="md-button md-button--primary" href="https://github.com/ucoruh/vs-net-core-template/releases/latest">:material-download: Download the latest release</a>
<a class="md-button" href="guide/use-the-template/">Start your project</a>

</div>

## Every report, per platform

Windows and Linux/WSL results are produced and kept **separately** (they can differ). Pick a platform:

<div class="grid cards" markdown>

- :fontawesome-brands-windows: **Windows**

    ---

    [Unit tests](reports/windows/tests-trx.md) ·
    [Coverage — ReportGenerator](reports/windows/coverage-reportgenerator.md) ·
    [Coverage — lcov](reports/windows/coverage-lcov.md) ·
    [Doc coverage — ReportGenerator](reports/windows/doccoverage-reportgenerator.md) ·
    [Doc coverage — lcov](reports/windows/doccoverage-lcov.md) ·
    [Doxygen](reports/windows/api-doxygen.md) ·
    [DocFX](reports/windows/api-docfx.md)

- :fontawesome-brands-linux: **Linux / WSL**

    ---

    [Unit tests](reports/linux/tests-trx.md) ·
    [Coverage — ReportGenerator](reports/linux/coverage-reportgenerator.md) ·
    [Coverage — lcov](reports/linux/coverage-lcov.md) ·
    [Doc coverage — ReportGenerator](reports/linux/doccoverage-reportgenerator.md) ·
    [Doc coverage — lcov](reports/linux/doccoverage-lcov.md) ·
    [Doxygen](reports/linux/api-doxygen.md) ·
    [DocFX](reports/linux/api-docfx.md)

</div>

## What is here

<div class="grid cards" markdown>

- :material-book-open-variant: **Guides**

    ---

    Install, use the template, from a topic to your own project, daily workflow, showing your project without
    GitHub Pages, troubleshooting. Türkçe: use the language switcher in the header.

    [:octicons-arrow-right-24: Start here](guide/install.md)

- :material-file-question: **Which report is which?**

    ---

    One page explaining every report, what it shows and how the two families differ.

    [:octicons-arrow-right-24: Read it](guide/reports-explained.en.md)

- :material-api: **API docs**

    ---

    Doxygen (framed here) and DocFX (a complete site of its own, opened in a new tab), for both platforms.

    [:octicons-arrow-right-24: API docs](api/index.md)

- :material-package-variant: **Downloads**

    ---

    Every release asset: apps, reports, API docs, the site, the source, checksums.

    [:octicons-arrow-right-24: Downloads](downloads.md)

- :material-projector-screen: **Show it without GitHub Pages**

    ---

    A private repository cannot use Pages on GitHub Free: build and show everything locally.

    [:octicons-arrow-right-24: Demo checklist](guide/showing-without-pages.en.md)

</div>

## Quick start

=== "Windows"

    ```batch
    4-install-tools-windows.bat
    7-build-all-windows.bat
    9-open-site-windows.bat
    ```

=== "Linux / WSL"

    ```bash
    chmod +x *.sh scripts/*.sh
    ./4-install-tools-linux.sh
    ./7-build-all-linux.sh
    ./9-open-site-linux.sh
    ```

`9-open-site` serves the site over a small local HTTP server and prints the URL — open that instead of
double-clicking `site/index.html`, so the report frames load.
