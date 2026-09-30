# Sitenizin içinde HTML raporu göstermek

Ana site **MkDocs Material** ile üretilir. **Bağımsız (standalone) HTML** olan her rapor, sitede kendi sayfasında
stilli, tam yükseklikte bir `<iframe>` içinde gösterilir; *Reports* ve *API docs* menüleri bu sayfaları listeler.

## Kural: yalnızca bağımsız HTML çerçevelenir

| Çerçevele (site üreticisinin *dışında* üretilmiş bağımsız HTML) | Yalnızca bağlantı ver, asla çerçeveleme (kendi site gezinmesi vardır) |
|---|---|
| ReportGenerator, lcov `genhtml`, VSTest/TRX HTML, Doxygen (kardeş şablonlarda JaCoCo, Javadoc, OpenCppCoverage, junit2html) | **DocFX** sayfaları (Java şablonunda tüm Maven site sayfaları: Surefire-report, Checkstyle, PMD, CPD, SpotBugs, JXR) |

Bir DocFX (veya Maven site) sayfasının kendi başlığı, menüsü ve araması vardır. Onu çerçevelemek *site içinde site*
oluşturur: iki menü, iki kaydırma çubuğu, çift gezinme. Bu yüzden ayrı üretilir, sitede `native/` altında (yerelde
`site-native/`) yayınlanır ve MkDocs menüsünden **bağlantı** verilir; yeni sekmede kendi sitesi olarak açılır.

Doğru ve yanlış:

```html
<!-- DOĞRU: bağımsız rapor, çerçeveli (docs/reports/windows/coverage-lcov.md) -->
<iframe class="report-frame" src="report/index.html" title="Coverage" loading="lazy"></iframe>

<!-- DOĞRU: kendi gezinmesi olan site, kendi başına açılacak şekilde bağlantı (docs/reports/windows/api-docfx.md) -->
<a class="md-button" href="../../../native/windows/index.html" target="_blank" rel="noopener">DocFX sitesini aç</a>

<!-- YANLIŞ: DocFX çerçevelenmiş, site sitenin içinde site gösteriyor -->
<iframe src="../../../native/windows/index.html"></iframe>
```

## Parçalar nasıl birleşir

1. Rapor `7-build-all-<platform>` ile `reports/<platform>/<tür>-<araç>/` altına yazılır (commit'lenmez).
2. `scripts/site_tools.py assemble-site` onu üretilen siteye `site/reports/<platform>/<tür>-<araç>/report/` olarak
   kopyalar (yanına İndir düğmesi için `report.zip`).
3. `docs/reports/<platform>/<tür>-<araç>.md` sayfası `site/reports/<platform>/<tür>-<araç>/` olur ve **göreli** bir
   yolla `report/index.html`'i çerçeveler; böylece hem GitHub Pages'te (`/<repo>/…`) hem yerelde çalışır.
4. `mkdocs.yml` içindeki `nav:` sayfayı *Reports* altında listeler.

## Kendi rapor sayfanızı ekleyin (5 adım)

Örnek: kendi aracınızın `reports/windows/mytool/index.html`'e yazdığı rapor.

1. **Derlemenin üretmesini sağlayın.** `7-build-all-windows.bat` (ve `.sh`) içinde raporu
   `reports\%PLATFORM_TOKEN%\mytool\` altına yazdırın.
2. **Klasörü kaydedin**: `scripts/site_tools.py` içindeki `REPORTS` sözlüğüne, örn.
   `"mytool": ("report-mytool", "My tool report", "Ne gösterdiği.")`. Böylece sürüme
   (`calculator-<sürüm>-windows-report-mytool.zip`) zip'lenir ve siteye kopyalanır.
3. **Sayfayı oluşturun**: `docs/reports/windows/mytool.md` (`coverage-lcov.md`'yi kopyalayıp başlığı, metni ve iki
   `report/index.html` yolunu değiştirin; yolları göreli tutun).
4. **`mkdocs.yml`'deki `nav:`'a ekleyin**:

    ```yaml
    - Reports:
        - Windows:
            - 'My tool': reports/windows/mytool.md
    ```

5. **Yerelde deneyin:** `7-build-all-windows.bat`, sonra `9-open-site-windows.bat`, sayfayı açın. Derleme, bitmiş site
   üzerinde bir bağlantı denetimi çalıştırır ve sayfalarınızdaki kırık bağlantıda hata verir.

## Sık sorunlar

| Belirti | Neden | Çözüm |
|---|---|---|
| Çerçeve boş ama *Open in a new tab* çalışıyor | `site/index.html`'e çift tıkladınız (`file://`); tarayıcılar `file://` sayfalarının çerçevelerini engeller | `9-open-site-<platform>` kullanın (`http://localhost:8080/`) |
| Çerçevede "bu makinede üretilmedi" notu | Diğer platformun raporu burada üretilmedi | O platformda derleyin veya sürümü indirin (CI ikisini de üretir) |
| Çerçevede 404 | Yanlış göreli yol ya da klasör kopyalanmadı (`REPORTS`'ta yok) | Sayfa adresi `reports/<platform>/<tür>/` olduğundan yol `report/…`'dir; `site/reports/…/report/` var mı bakın |
| `check-links` kırık bağlantı bildiriyor | Bir sayfa var olmayan bir şeye bağlanıyor | Yazdırdığı yolu düzeltin (o HTML dosyasına göre göreli) |
| Gerçek bir web sitesinde çerçeveli sayfa yüklenmiyor | Sunucu `X-Frame-Options: DENY` gönderiyor | Yeni sekmede bağlantı verin; GitHub Pages bunu göndermez, yalnızca başka barındırıcıları etkiler |
| Çerçevedeki DocFX/Maven sayfasında iki menü var | Kendi gezinmesi olan bir siteyi çerçevelediniz | Çerçevelemeyin, bağlantı verin (yukarıdaki kural) |

## İki dil: `/` ve `/tr/` altından iframe yolu

Site iki dillidir (`mkdocs-static-i18n`, suffix modu): her sayfa iki kez bulunur, `ad.en.md` (İngilizce, site kökünde) ve
`ad.tr.md` (Türkçe, `/tr/` altında). Rapor dosyaları **bir kez**, `site/reports/<platform>/<tür>/report/` altına kopyalanır.
İki sayfa sürümü bu yüzden onlara farklı yollarla ulaşır:

| Sayfa | Adres | Iframe `src` |
|---|---|---|
| `docs/reports/windows/coverage-lcov.en.md` | `/reports/windows/coverage-lcov/` | `report/index.html` (sayfaya göre göreli) |
| `docs/reports/windows/coverage-lcov.tr.md` | `/tr/reports/windows/coverage-lcov/` | `../../../../reports/windows/coverage-lcov/report/index.html` (site köküne dört seviye yukarı) |

Her zaman **göreli** yol kullanın (asla `/reports/...` değil): GitHub Pages'in `/<repo>/` önekinde ve
`http://localhost:8080/` üzerinde çalışmaya devam eder. Sayfa eklerken hem `.en.md` hem `.tr.md` ekleyin ve başlığı
`mkdocs.yml` içindeki `nav_translations` altına kaydedin; `check-links` iki dili de doğrular.
