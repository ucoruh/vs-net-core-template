# Projenizi GitHub Pages olmadan göstermek

Deponuz **özel (private)** ve büyük olasılıkla **GitHub Free** kullanıyorsunuz. Orada GitHub Pages özel bir depoyu
yayınlamaz (GitHub Pro/Team gerekir; ücretsiz
[GitHub Student Developer Pack](https://education.github.com/pack) Pro'yu içerir). Bu sizi **durdurmaz**: sitenin
tamamı (her rapor, iki platform, API dokümanları) **kendi bilgisayarınızda** üretilir ve gösterilir; her çıktı
`release/` klasöründe toplanır. Sürümler (Releases) özel depolarda **çalışır**.

## Bir kez her şeyi üretin

=== "Windows"

    ```batch
    7-build-all-windows.bat
    9-open-site-windows.bat
    ```

=== "Linux / WSL"

    ```bash
    ./7-build-all-linux.sh
    ./9-open-site-linux.sh
    ```

`9-open-site` küçük bir web sunucusu başlatır ve **http://localhost:8080/** adresini açar. `site/index.html`'e çift
tıklamak yerine bunu kullanın: tarayıcılar `file://` sayfalarının çerçevelerini engeller, rapor sayfaları boş kalır.
Sunucuyu **Ctrl+C** ile durdurun.

Windows ve Linux/WSL raporları ayrı üretilir ve ayrı tutulur (farklı olabilirler). Yerel siteniz, üzerinde
derlediğiniz platformu tam gösterir; diğer platformun sayfalarında "bu makinede üretilmedi" notu olur. Sunumda ikisini
de göstermek için iki platformda da derleyin (Windows, sonra WSL) ya da CI'ın ikisini de üretmesini bekleyip sürümü indirin.

## Sunum kontrol listesi

Proje sunumunda sırayla:

1. **Yerel site ana sayfası**: `http://localhost:8080/`: başlık, rozetler, rapor kartları.
2. **Her rapor sayfası**, *Reports* menüsünden (Windows / Linux): birim testleri, kapsama (ReportGenerator ve lcov),
   dokümantasyon kapsaması (ikisi de). Her birinin ne gösterdiğini söyleyin; *Open in a new tab* tam raporu açar.
3. **API dokümanları**: *API docs* menüsü: Doxygen (çerçevede) ve DocFX (yeni sekmede kendi sitesi olarak).
4. **`release/` klasörü**: listeyi ve `ASSETS.md`'yi gösterin: uygulama arşivi, her rapor zip'i, API dokümanları,
   `…-site.zip`, `…-source.zip`, `SHA256SUMS.txt`.
5. **Uygulamayı sürüm arşivinden çalıştırın**: `calculator-<sürüm>-windows-x64-app.zip`'i boş bir klasöre açın
   (Linux: `tar -xzf calculator-<sürüm>-linux-x64-app.tar.gz`) ve orada `CalculatorApp`'i çalıştırın; .NET kurulu
   olması ya da çevrede depo bulunması gerekmez:

    ```batch
    CalculatorApp.exe add 2 3
    ```

6. **Testler**: `6-build-and-test-<platform>` 39 testin saniyeler içinde geçtiğini gösterir.

## Aynı dosyalar bir GitHub Release'te (özel depolarda çalışır)

`10-release-<platform>` her şeyi üretir ve `release/` klasörünü GitHub CLI (`gh`) ile GitHub Release olarak yayınlar.
Önce `gh`'nin giriş yapmış olduğunu ve çalışma ağacının temiz olduğunu kontrol eder; önce `--dry-run` ile deneyin:

```batch
10-release-windows.bat --dry-run
10-release-windows.bat
```

Sürüm, `project.env` içindeki `VERSION`'dır (düzenleyin, commit'leyin, yayınlayın). İşbirlikçiler (ders sorumlusu)
sürümü ve her dosyayı görür. Site `…-site.zip` olarak iner: açın, o klasörde `python -m http.server 8080` çalıştırıp
`http://localhost:8080/` adresini açın.

Ayrıntılar, Free-Pro tablosu ve Student Pack adımları: [Sürümler ve özel depolar](releases-and-private-repos.tr.md).
