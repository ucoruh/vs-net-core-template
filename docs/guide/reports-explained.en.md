# Which report is which?

`7-build-all` produces **every report twice**: with the modern, cross-ecosystem tool (ReportGenerator) and with the
older / native tool, so you see the same numbers rendered both ways. And it produces them **per platform**:
once on Windows, once on Linux/WSL, kept apart (they can differ).

| # | Report | Modern family | Native / older family | Folder (`reports/<platform>/...`) |
|---|---|---|---|---|
| 1 | Unit tests | - | `dotnet test` TRX + VSTest HTML logger | `tests-trx/` |
| 2 | Code coverage | ReportGenerator (cobertura) | - | `coverage-reportgenerator/` |
| 3 | Code coverage | - | lcov `genhtml` (coverlet's lcov output) | `coverage-lcov/` |
| 4 | Documentation coverage | ReportGenerator (coverxygen lcov) | - | `doccoverage-reportgenerator/` |
| 5 | Documentation coverage | - | lcov `genhtml` (same lcov file) | `doccoverage-lcov/` |
| 6 | API docs | - | Doxygen (same tool in all three templates) | `api-doxygen/` |
| 7 | API docs | DocFX (C#-native) | - | `api-docfx/` (also `site-native/`) |
| 8 | The main site | MkDocs Material | - | `site/` |

In the site, #1 to #6 are shown in a frame; #7 is a complete site of its own and is linked (opens in a new tab). See
[Showing an HTML report inside your site](embed-html-in-site.en.md).

## How to read each one

**Unit test results (#1).** A pass/fail list with durations. Open it when a test fails and you want the exact
assertion message without touching the terminal.

**Code coverage, ReportGenerator (#2).** Per-file, per-line coverage with a red/green gutter, a trend graph across
builds (history in `report_history/<platform>/`), and the small SVG badges under `docs/assets/`. Use this day to day.

**Code coverage, lcov (#3).** The same numbers in lcov's classic directory-tree view, generated from the same
`coverage.info` a C++ project produces, just written by coverlet instead of gcov.

**Documentation coverage (#4, #5).** Not "how much code is tested" but "how much of the public API has an XML doc
comment (`/// <summary>`)". [coverxygen](https://github.com/psycofdj/coverxygen) turns Doxygen's XML into the same lcov
format code coverage uses, so either tool can render it. In the sample it is intentionally not 100%: `Program` and the
README's narrative text are not meant to carry API comments.

**Doxygen (#6).** Renders the C# XML doc comments the way it renders `\brief`/`\param` comments in C or C++: the
one API doc every template produces the same way.

**DocFX (#7).** Generated from the assembly's XML documentation file; what a professional .NET project ships (compare
Microsoft's own API docs). It understands generics, nullable annotations and inheritance better than Doxygen.

## Why per platform?

Coverage and test results can differ between Windows and Linux (path handling, line endings, platform-specific
code, other tool versions). Keeping them apart, with the platform in every folder and file name, makes the
difference visible instead of one platform silently overwriting the other.

## Why not just pick one tool?

Because on the job you will not get to choose. Seeing the same numbers rendered two ways from day one means neither
style is a surprise later.
