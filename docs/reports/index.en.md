# Reports

Every report is produced **twice**, once on **Windows** and once on **Linux/WSL**, and the two sets are kept
apart (they can differ: other compiler output, other line endings, other tools). For each kind there are
**two tool families** so you can compare them:

| Kind | Modern family | Older / native family |
|---|---|---|
| Unit tests | — | TRX + VSTest HTML logger (`dotnet test`) |
| Code coverage | ReportGenerator (cobertura) | lcov / `genhtml` (lcov output of coverlet) |
| Documentation coverage | ReportGenerator (coverxygen lcov) | lcov / `genhtml` (coverxygen lcov) |
| API docs | DocFX (C# native) | Doxygen (all three templates) |

Standalone reports open **inside this site** in a frame; DocFX is a site of its own and opens in a new tab.
The rule and a right/wrong example: [Showing an HTML report inside your site](../guide/embed-html-in-site.en.md).
What each report shows: [Which report is which?](../guide/reports-explained.en.md).

| Report | Windows | Linux / WSL |
|---|---|---|
| Unit tests | [open](windows/tests-trx.md) | [open](linux/tests-trx.md) |
| Code coverage — ReportGenerator | [open](windows/coverage-reportgenerator.md) | [open](linux/coverage-reportgenerator.md) |
| Code coverage — lcov | [open](windows/coverage-lcov.md) | [open](linux/coverage-lcov.md) |
| Doc coverage — ReportGenerator | [open](windows/doccoverage-reportgenerator.md) | [open](linux/doccoverage-reportgenerator.md) |
| Doc coverage — lcov | [open](windows/doccoverage-lcov.md) | [open](linux/doccoverage-lcov.md) |
| API docs — Doxygen | [open](windows/api-doxygen.md) | [open](linux/api-doxygen.md) |
| API docs — DocFX | [open](windows/api-docfx.md) | [open](linux/api-docfx.md) |

!!! note "A platform shows a placeholder page"
    A local build only knows the platform you built on. The other platform's pages then say so; CI builds
    both, so the live site has everything.
