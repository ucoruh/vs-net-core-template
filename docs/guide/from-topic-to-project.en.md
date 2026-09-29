# From a project topic to your own project

This walks through turning the sample `Calculator*` project into a real project, using **"Library
Management System"** (a typical course project-guide topic) as the worked example. Substitute your
own topic's name throughout.

## Checklist

- [ ] Pick a short PascalCase project name (`LibraryCatalog`, not `Library Management System`).
- [ ] Rename the solution, the three project folders and their `.csproj` files.
- [ ] Rename the root namespace in each `.csproj` (`RootNamespace`) and every `namespace` block.
- [ ] Update `Doxyfile`'s `PROJECT_NAME`/`PROJECT_BRIEF`, `docfx.json`'s metadata `src`, and the
      titles in `toc.yml`/`docs/toc.yml`.
- [ ] Replace `README.md` with your own project's description (it becomes `docs/index.md`, the site's
      home page -- see [Which report is which?](reports-explained.en.md)).
- [ ] Write tests **first** for each new class, the same way `CalculatorCliTests.cs` tests
      `CalculatorCli` before you'd trust it.
- [ ] Keep the "parsing lives in the library, not in `Program.cs`" shape (see below) so your own
      command-line handling stays testable.
- [ ] Run `7-build-app` after every rename step -- do not batch every change together and hope.

## Step by step (the "LibraryCatalog" example)

**1. Rename the folders and files.**

```bash
git mv CalculatorLibrary LibraryCatalog
git mv CalculatorLibrary/CalculatorLibrary.csproj LibraryCatalog/LibraryCatalog.csproj
git mv CalculatorLibrary/Calculator.cs LibraryCatalog/Book.cs                # or your first real class
git mv CalculatorLibrary/CalculatorCli.cs LibraryCatalog/LibraryCatalogCli.cs

git mv CalculatorApp CalculatorApp.old && git mv CalculatorApp.old LibraryCatalogApp
git mv LibraryCatalogApp/CalculatorApp.csproj LibraryCatalogApp/LibraryCatalogApp.csproj

git mv CalculatorLibrary.Tests LibraryCatalog.Tests
git mv LibraryCatalog.Tests/CalculatorLibrary.Tests.csproj LibraryCatalog.Tests/LibraryCatalog.Tests.csproj
git mv LibraryCatalog.Tests/CalculatorTests.cs LibraryCatalog.Tests/BookTests.cs
git mv LibraryCatalog.Tests/CalculatorCliTests.cs LibraryCatalog.Tests/LibraryCatalogCliTests.cs
```

(`git mv CalculatorApp CalculatorApp.old && git mv ... LibraryCatalogApp` works around Windows'
case-insensitive filesystem when only the app-vs-library naming differs; a plain `git mv A B` is
usually enough when the names genuinely differ, as above.)

**2. Update the solution file.** Open `CalculatorLibrary.sln` in a text editor (or `dotnet sln`) and
replace the three project names/paths, then rename the file itself:

```bash
git mv CalculatorLibrary.sln LibraryCatalog.sln
```

```bash
dotnet sln LibraryCatalog.sln remove LibraryCatalog/LibraryCatalog.csproj 2>/dev/null || true
dotnet sln LibraryCatalog.sln add LibraryCatalog/LibraryCatalog.csproj LibraryCatalogApp/LibraryCatalogApp.csproj LibraryCatalog.Tests/LibraryCatalog.Tests.csproj
```

(Simplest in practice: delete the `.sln` and regenerate it with `dotnet new sln -n LibraryCatalog`
followed by three `dotnet sln add` calls -- faster than hand-editing the GUIDs.)

**3. Rename the namespace everywhere.** Every `.cs` file in this template wraps its content in
`namespace CalculatorLibrary { ... }` / `namespace CalculatorApp { ... }` /
`namespace CalculatorLibrary.Tests { ... }`. Do a project-wide find-and-replace
(`CalculatorLibrary` -> `LibraryCatalog`, `CalculatorApp` -> `LibraryCatalogApp`) across `*.cs`
files, and set `<RootNamespace>` in each `.csproj` to match.

**4. Replace the sample class.** `Book.cs` (renamed from `Calculator.cs`) becomes your first real
class -- delete the arithmetic methods, add your own, and give every public member the same kind of
XML doc comment (`<summary>`, `<param>`, `<returns>`) the sample used, so Doxygen and DocFX keep
working.

**5. Keep parsing in the library.** `LibraryCatalogCli.cs` (renamed from `CalculatorCli.cs`) is the
pattern to keep: a static class with a `Run(string[] args)` method that parses and executes, returning
a string, throwing `ArgumentException` with a clear message on bad input. `Program.cs` stays a thin
shell that calls it and prints the result -- this is what makes the parsing logic unit-testable
without starting the app as a process, and keeps `Program.cs` itself free of logic worth testing.

**6. Write tests first.** For every new public method: one normal-case test, one boundary-case test
(empty input, zero, the smallest/largest value that makes sense for your domain), one invalid-input
test. `CalculatorTests.cs`/`CalculatorCliTests.cs` show the shape (`[Theory]` + `[InlineData]` for
normal/boundary cases, `Assert.Throws<T>` for invalid input).

**7. Update the docs.**

- `Doxyfile`: `PROJECT_NAME`, `PROJECT_BRIEF`, and the `INPUT` list (folder names changed).
- `docfx.json`: the `metadata[0].src[0].src` path (`LibraryCatalog` instead of `CalculatorLibrary`).
- `toc.yml` / `docs/toc.yml`: page titles that still say "Calculator".
- `README.md`: your project's real description (this becomes the site's home page).

**8. Rebuild and check.**

```batch
7-build-app.bat
9-open-site.bat
```

Confirm: the build has 0 warnings, all your tests pass, the API reference under `site/api/` lists
your classes (not `Calculator`), and coverage is where you expect it.

## What "keep coverage" means in practice

Do not let the sample's 100% line coverage quietly drop to 60% because you added code without tests.
Run `7-build-app` after each new class and check `docs/coveragereport/index.html`
([Which report is which?](reports-explained.en.md)) before you move on to the next one -- it is much
easier to write the missing test right away than to reconstruct intent for ten untested methods later.

## Next

[Daily workflow](daily-workflow.en.md).
