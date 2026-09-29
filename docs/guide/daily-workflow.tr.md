# Günlük iş akışı

## Tüm scriptler, tek tabloda

| Script | Ne yapar | Ne zaman çalıştırılır |
|--------|----------|------------------------|
| `1-pre-commit` | Git kancası (hook): her commit'ten önce eklenen (staged) `.cs`/`.c`/`.cpp`/`.h`/`.java` dosyalarını astyle ile biçimlendirir | bir kez `.git/hooks/pre-commit`'e kopyalayın (aşağıda), sonra otomatik çalışır |
| `2-create-git-ignore` | `.gitignore`'ın toptal.com tabanını yeniden üretir, bu projenin kendi eklerini korur | nadiren, yalnızca henüz göz ardı (ignore) kuralınız olmayan bir dil gerektiğinde |
| `3-install-package-manager` | Chocolatey/Scoop kurar (Windows) ya da `apt`'ı tazeler (WSL) | makine başına bir kez |
| `4-install-dotnet-sdk` | `global.json`'da sabitlenen .NET SDK'sını kullanıcı bazlı kurar | makine başına bir kez |
| `4-install-astyle` / `4-install-coverxygen` / `4-install-lcov` | Biçimlendirici, belge-kapsama ve lcov araçlarını kurar | makine başına bir kez |
| `5-format-code` | Üç C# proje klasörü üzerinde astyle çalıştırır | commit'ten önce, ya da git kancasına bırakın |
| `6-install-docfx-and-report-tools` | Doxygen/Graphviz kurar, sabitlenmiş yerel `dotnet tool` bildirimini (manifest) geri yükler (ReportGenerator, DocFX) | makine başına bir kez, `.config/dotnet-tools.json` değiştiğinde tekrar |
| `7-build-app` | Geri yükleme (restore), derleme, kapsamayla test, Doxygen, her iki kod-kapsama rapor ailesi, her iki belge-kapsama rapor ailesi, DocFX sitesi | ne zaman taze rapor istiyorsanız |
| `8-run-app` | Örnek uygulamayı çalıştırır (verilen argümanları iletir); girdi (input) beklemez, asla bloklamaz | uygulamanın kendisini denemek için |
| `9-open-site` | `site/index.html`'i açar | `7-build-app`'ten sonra |
| `10-release` | İkilileri (binaries) + her raporu + siteyi `site.zip` olarak paketler, `gh` ile bir GitHub Release yayınlar | bir sürümü teslim etmeye hazır olduğunuzda (bkz. [Sürümler ve özel depolar](releases-and-private-repos.tr.md)) |

## Pre-commit kancasını bir kez kurun

```bash
cp 1-pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit   # WSL/macOS; Windows'ta zararsız, etkisiz
```

Bundan sonra her `git commit`, eklediğiniz `.cs` dosyalarını `astyle-options.txt`'deki kurallarla
otomatik biçimlendirir; `.gitignore`, `README.md` veya `Doxyfile` eksikse commit'i reddeder.

## Dal (branch), commit, push, CI

1. `git checkout -b feature/<kisa-ad>` -- doğrudan `main`'e commit atmayın.
2. Önce testi, sonra kodu yazın, ardından `7-build-app.bat`/`.sh`'i çalıştırıp
   `docs/coveragereport/index.html`'in düşmediğini kontrol edin.
3. Küçük, mantıklı adımlarla, açık bir mesajla commit atın (emir kipi: "Add X", "Added X" veya
   "Stuff" değil).
4. `git push -u origin feature/<kisa-ad>`, `main`'e bir çekme isteği (pull request) açın.
5. GitHub Actions (`.github/workflows/build_check_ubuntu_windows.yml`) hem Windows hem Ubuntu'da
   otomatik olarak geri yükler, derler ve test eder -- birleştirmeden (merge) önce yeşil olmasını
   bekleyin. Her push'ta hiçbir şey **yayınlamaz** (bu, elle çalıştırılan `10-release`'in işi); ayrı,
   elle tetiklenen sürüm iş akışı ve dakika maliyeti için bkz.
   [Sürümler ve özel depolar](releases-and-private-repos.tr.md).
6. PR incelendikten (varsa bir takım arkadaşınız tarafından) ve CI yeşil olduktan sonra birleştirin.

## Her şey nereye gider

`docs/` ve `site/` altındaki her şey `7-build-app` tarafından üretilir ve commit **edilmez** (bkz.
`.gitignore`) -- README'nin gösterdiği ve bir derleme çalıştırılmadan GitHub'da görünmesi için
commit edilmeye değer olan `assets/` altındaki küçük SVG rozetler dışında.

| Ne | Yol |
|----|-----|
| Bütün site | `site/index.html` |
| Her bir rapor | bkz. [Hangi rapor hangisi?](reports-explained.tr.md) |
| Sürüm paketleri | `release/` (`10-release`'den, o da commit edilmez) |

## Sırada

[Sürümler ve özel depolar](releases-and-private-repos.tr.md), ya da bir şey başarısız olduysa
[Sorun giderme](troubleshooting.tr.md).
