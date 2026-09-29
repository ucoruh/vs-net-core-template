# Which report is which?

`7-build-app` produces **every report twice**: once with the modern, cross-ecosystem
[ReportGenerator](https://reportgenerator.io/) tool, and once with the older, ecosystem-native tool
most C/C++/Linux engineers already know. They show the same underlying data in a different style --
comparing them is the point: you will meet both families in real jobs.

| # | Report | Tool | Family | Where it lands |
|---|--------|------|--------|-----------------|
| 1 | Unit test results | VSTest's built-in HTML logger | native | `docs/testresults/test-results.html` (+ `test-results.trx`, the raw XML Visual Studio reads) |
| 2 | Code coverage | [ReportGenerator](https://reportgenerator.io/) (reads coverlet's Cobertura output) | ReportGenerator | `docs/coveragereport/index.html` |
| 3 | Code coverage | `genhtml` (reads coverlet's lcov output) | native (lcov, the Linux/C++ world's default) | `docs/coverage-genhtml/index.html` |
| 4 | Documentation coverage | `genhtml` (reads coverxygen's lcov output) | native | `docs/coverxygen/index.html` |
| 5 | Documentation coverage | ReportGenerator (reads the same lcov file) | ReportGenerator | `docs/doccoverage-reportgenerator/index.html` |
| 6 | API docs, ecosystem-neutral | [Doxygen](https://www.doxygen.nl/) | native (same tool the C/C++ and Java templates use) | `docs/doxygen/html/index.html` |
| 7 | API reference, C#-native | [DocFX](https://dotnet.github.io/docfx/) metadata step | ecosystem-native | `site/api/` |
| 8 | The whole site | DocFX build | -- | `site/index.html` (open it with `9-open-site`) |

## How to read each one

**Unit test results (native, #1).** A plain pass/fail list with durations -- this is what a CI dashboard
usually links to first. Open `test-results.html` when a test fails and you want the exact assertion
message without touching the terminal.

**Code coverage -- ReportGenerator (#2).** Per-file, per-line coverage with a red/yellow/green gutter,
a trend graph across builds (kept in `report_history/`, see `.gitignore`), and the small SVG badges
under `assets/` that the README embeds. Use this one day to day.

**Code coverage -- genhtml (#3).** The same numbers, lcov's classic directory-tree view. If you have
used `lcov`/`gcov` in a C/C++ project before, this will look familiar; it is generated from exactly
the same `coverage.info` file a C++ project would produce, just written by coverlet instead of gcov.

**Documentation coverage (#4, #5).** Not "how much code is *tested*" but "how much of the public API
has an XML doc comment (`/// <summary>...`)". [coverxygen](https://github.com/psycofdj/coverxygen)
turns Doxygen's XML output into the same lcov format code coverage uses, so it can be rendered by
either tool. In this template's sample, documentation coverage is intentionally **not** 100%: the
`Program` class and `README.md`'s narrative text are not meant to carry Doxygen-style API comments,
so they count as "undocumented" lines -- that is expected, not a bug.

**Doxygen (#6).** Renders `/// <summary>`, `<param>`, `<returns>` and `<exception>` C# XML doc
comments the same way it would render `\brief`/`\param` comments in a C or C++ project. It is the one
report every template (C, Java, C#) produces the same way, which is why it is useful even though C#
has its own, more idiomatic tool (#7).

**DocFX API reference (#7).** Generated straight from the compiled assembly's XML documentation file
(`CalculatorLibrary.xml`, produced by `<GenerateDocumentationFile>true</GenerateDocumentationFile>`
in `CalculatorLibrary.csproj`) -- this is what a professional .NET project actually ships (compare it
to [Microsoft's own API docs](https://learn.microsoft.com/dotnet/api/), which are built the same way).
It understands C# generics, nullable annotations and inheritance better than Doxygen does.

**The site (#8).** Everything above, plus the guides you are reading now, linked from one place --
its landing page is a card grid (source: `docs/home.md`), and every report above gets its own page
inside the site showing it in a styled `<iframe>` rather than a bare link (source:
`docs/report-pages/*.md`; see [Showing a report inside your site](embed-html-in-site.en.md)). See
[Daily workflow](daily-workflow.en.md) for what to run and in what order.

## Why not just pick one tool?

Because you will not get to choose on the job. Some teams standardize on ReportGenerator, others
still run whatever their C/C++ pipeline has always used, and documentation tooling is even less
consistent. Seeing the same numbers rendered two different ways, from day one, means neither style is
a surprise later.
