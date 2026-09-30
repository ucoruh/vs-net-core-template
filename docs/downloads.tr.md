# İndirmeler

Derlemenin ürettiği her şey, yerel `release/` klasörüyle **birebir** aynı olarak her GitHub Release'e eklenir.
**[Son sürüm ↗](https://github.com/ucoruh/vs-net-core-template/releases/latest)**

Dosya adları, üç şablonda da aynı olan tek bir kalıbı izler:

```text
<proje>-<sürüm>[-<platform>[-<arch>]]-<içerik>[-<araç>].<uzantı>
calculator-2.1.2-windows-x64-app.zip
calculator-2.1.2-linux-x64-app.tar.gz          calculator-2.1.2-macos-arm64-app.tar.gz   (CI üretir)
calculator-2.1.2-windows-report-tests.zip      calculator-2.1.2-linux-report-coverage-lcov.zip
calculator-2.1.2-linux-api-doxygen.zip         calculator-2.1.2-windows-api-docfx.zip
calculator-2.1.2-source.zip   calculator-2.1.2-site.zip   ASSETS.md   SHA256SUMS.txt
```

- Platform: `windows`, `linux` (yerel Linux **ve** WSL), `macos` (yalnız CI, yalnız uygulama). Mimari `x64` / `arm64`
  yalnızca ikili dosya adlarında görünür.
- Windows ikilileri ve her HTML raporu için `.zip`; Linux/macOS ikilileri için `.tar.gz` (çalıştırma bitini korur).
- `proje` ve `sürüm` `project.env` içinden gelir.
- Sürümdeki `ASSETS.md` her dosyayı platformu, içeriği, aracı ve site bağlantısıyla listeler; `SHA256SUMS.txt` indirmeyi
  doğrulamanızı sağlar (`sha256sum -c SHA256SUMS.txt`).
- `site.zip` bu sitenin iki platformun raporlarıyla birlikte tamamıdır. Açın ve sunun (klasörde
  `python -m http.server`) ya da bkz. [Projenizi GitHub Pages olmadan göstermek](guide/showing-without-pages.tr.md).

Eski betik adları ve yeni adları: [README](https://github.com/ucoruh/vs-net-core-template#old-name--new-name) içindeki tablo.
