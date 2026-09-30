# Günlük iş akışı

## Betikler: aynı numara = aynı iş, platform sonek olarak

Her betik `NN-ad-windows.bat` ve `NN-ad-linux.sh` olarak vardır (yerel Linux ve WSL ikisi de `linux`). Yardımcılar
`scripts/` altındadır. Proje adı ve sürüm **`project.env`** dosyasından gelir.

| Betik | Ne yapar | Ne zaman |
|---|---|---|
| `1-configure-git-hooks` | pre-commit kancasını (astyle) kurar | klon başına bir kez |
| `2-create-gitignore` | `.gitignore`'u yeniler, projeye özel bölümü korur | nadiren |
| `3-install-package-manager` (yalnız Windows) | Chocolatey + Scoop | makine başına bir kez |
| `4-install-tools` | .NET SDK, Doxygen, lcov, astyle, dotnet araçları, MkDocs Material, coverxygen | makine başına bir kez |
| `5-format-code` | üç C# projesinde astyle | commit öncesi (veya kanca yapsın) |
| `6-build-and-test` | **hızlı**: derleme (Debug) + birim testleri | her değişiklikten sonra |
| `7-build-all` | derleme, kapsamalı testler, her rapor (iki aile), Doxygen + DocFX, uygulama, site, `release/` | push öncesi ve sunum için |
| `8-run-app` | örnek uygulamayı çalıştırır (`add 2 3`) | denemek için |
| `9-open-site` | `site/`'ı `http://localhost:8080/`'de sunar ve açar | siteye bakmak için |
| `10-release` | her şeyi üretir ve `gh` ile GitHub Release yayınlar (önce `--dry-run`) | teslimde |
| `11-clean` | üretilen her klasörü siler | bir şey eskimiş görünürse |

### Eski ad → yeni ad

| Eski | Yeni |
|---|---|
| `1-pre-commit` | `scripts/hooks/pre-commit` (`1-configure-git-hooks-*` kurar) |
| `2-create-git-ignore.bat/.sh` | `2-create-gitignore-windows.bat` / `-linux.sh` |
| `3-install-package-manager.bat` | `3-install-package-manager-windows.bat` (`.sh` kaldırıldı: apt, `4-install-tools-linux.sh` içinde) |
| `4-install-dotnet-sdk`, `4-install-astyle`, `4-install-coverxygen`, `4-install-lcov`, `6-install-docfx-and-report-tools` | hepsi `4-install-tools-windows.bat` / `-linux.sh` içinde (SDK ve pip kısımları `scripts/` yardımcıları) |
| `5-format-code.bat/.sh` | `5-format-code-windows.bat` / `-linux.sh` |
| *(yeni)* | `6-build-and-test-windows.bat` / `-linux.sh` |
| `7-build-app.bat/.sh` | `7-build-all-windows.bat` / `-linux.sh` |
| `8-run-app.bat/.sh` | `8-run-app-windows.bat` / `-linux.sh` |
| `9-open-site.bat/.sh` | `9-open-site-windows.bat` / `-linux.sh` |
| `10-release.bat/.sh` | `10-release-windows.bat` / `-linux.sh` |
| *(yeni)* | `11-clean-windows.bat` / `-linux.sh` |
| `dotnet-env.bat/.sh` | `scripts/dotnet-env-windows.bat` / `-linux.sh` |
| `VERSION` | `project.env` içinde `VERSION=` |
| `docs/testresults`, `docs/coveragereport`, `docs/doxygen`, … | `reports/<platform>/<tür>-<araç>/` |
| `docfx.json`, `toc.yml` (DocFX ana sayfaydı) | `docfx/` (DocFX artık `native/` altında API referansı); ana site MkDocs (`mkdocs.yml`) |
| `pages.yml`, `release.yml` | tek boru hattı, `ci.yml` |

## Sıradan bir gün

1. `git checkout -b feature/my-change`
2. Önce testi, sonra kodu yazın, ardından `6-build-and-test-<platform>` (saniyeler).
3. Push öncesi `7-build-all-<platform>` çalıştırın ve kapsamanın düşmediğine bakın.
4. `git commit`, `git push`, pull request açın; CI Windows, Linux ve macOS'ta derler.

## Her şey nereye düşer (hepsi gitignore'da)

| Klasör | İçerik |
|---|---|
| `build/<platform>-<config>/` | derleyici çıktısı (`dotnet --artifacts-path`); Windows ve WSL çakışmaz |
| `publish/<platform>-<arch>/` | uygulama, kendi kendine yeten |
| `reports/<platform>/<tür>-<araç>/` | `tests-trx`, `coverage-reportgenerator`, `coverage-lcov`, `doccoverage-reportgenerator`, `doccoverage-lcov`, `api-doxygen`, `api-docfx` |
| `site/` | MkDocs sitesi (ana site): `9-open-site` |
| `site-native/` | DocFX sitesi (`native/` altında yayınlanır) |
| `release/` | her sürüm dosyası, GitHub'dakiyle aynı adlar, ayrıca `ASSETS.md` ve `SHA256SUMS.txt` |

Yalnızca `docs/assets/` altındaki küçük SVG rozetler commit'lenir (README ve site bunları gömer).
