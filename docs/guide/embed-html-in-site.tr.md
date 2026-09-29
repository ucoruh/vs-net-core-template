# Sitenizin içinde bir raporu göstermek

Bu şablonun ürettiği her rapor (birim testleri, her iki kapsam ailesi, her iki dokümantasyon-kapsamı
ailesi, Doxygen) DocFX sitesinin **içinde**, düzenli ve duyarlı (responsive) bir `<iframe>` içinde
gösterildiği kendi sayfasına sahiptir — sadece ham bir HTML dosyasına düz bir bağlantı değil. Bu
sayfa bunun nasıl çalıştığını anlatır; böylece kendi eklediğiniz **yeni** bir rapor için (bir linter,
bir statik analiz aracı, HTML üreten herhangi bir şey) kendi sayfanızı ekleyebilirsiniz.

## Üç parça

1. **Raporun kendisi** — `7-build-app`'in `docs/<bir-şey>/` altında ürettiği bir HTML dosyası (veya
   klasörü) (ör. `docs/coveragereport/index.html`). Bunu siz yazmazsınız.
2. **`docfx.json` içinde bir resource eşlemesi** — bu klasörü üretilen sitenin içine,
   `site/docs/reports/...` altına kopyalar. Şablonun kendi ürettiği her rapor için zaten mevcuttur;
   yalnızca kendi eklediğiniz bir rapor ailesi için yenisini eklemeniz gerekir.
3. **Bir görüntüleyici sayfa** — `docs/report-pages/` altında, `<iframe>`'i, araç çubuğu
   düğmelerini ve açıklayıcı metni içeren küçük bir Markdown dosyası. `docs/toc.yml`'nin "Reports"
   bölümü ham rapor dosyasına değil, buraya bağlanır.

## Kopyala-yapıştır örneği

Yeni bir rapor için sayfa eklemek (örneğin `docs/mytool/index.html`'e yazılan hayali bir `mytool`
HTML raporu için):

**1. `docfx.json`'ın onu kopyaladığından emin olun.** Mevcut girişlerin yanına, rapor klasörünün
`site/docs/reports/` altına inmesini sağlayan bir `resource` girişi ekleyin:

```json
{ "files": [ "mytool/**" ], "src": "docs", "dest": "docs/reports" }
```

**2. `docs/report-pages/mytool.md` dosyasını oluşturun:**

```markdown
# My Tool Report

Bu raporun ne gösterdiğini ve ne zaman bakılması gerektiğini anlatan tek cümle.

<div class="report-toolbar">
  <a href="../reports/mytool/index.html" target="_blank" rel="noopener">Yeni sekmede aç ↗</a>
  <a href="../reports/mytool/mytool-report.zip" download>İndir (zip)</a>
</div>

<div class="report-frame-wrap">
  <iframe class="report-frame" src="../reports/mytool/index.html" title="My Tool Report" loading="lazy"></iframe>
</div>

<p class="report-fallback">Yukarıdaki çerçeve boş kalırsa, doğrudan açın:
<a href="../reports/mytool/index.html">docs/reports/mytool/index.html</a>.</p>
```

`../reports/...` yolları, bu sayfanın derlemeden sonra ineceği `docs/report-pages/mytool.html`
dosyasına görelidir — `report-pages/` klasöründen bir `../` ile çıkıp, 1. adımdaki resource
eşlemesinin raporu koyduğu `reports/mytool/...` klasörüne girer. Dört CSS sınıfı da
(`report-toolbar`, `report-frame-wrap`, `report-frame`, `report-fallback`)
`templates/rteu/public/main.css`'ten gelir (özel bir DocFX şablon katmanı, bkz. `docfx.json`'ın
`"template"` dizisi) — tam yükseklikte, duyarlı bir çerçeve; `loading="lazy"` sayesinde ekrana
gelene kadar yüklenmez.

**3. İsteğe bağlı: bir "İndir (zip)" düğmesi.** `7-build-app`, her raporun kendi klasörünü olduğu
yerde ziplediği için (`7-build-app.bat`/`.sh`'nin 7. adımı) zip dosyası `index.html`'in hemen
yanına düşer ve aynı resource eşlemesi tarafından otomatik olarak alınır. Derleme betiğinizin zip
adımına bir satır daha ekleyin, örnek:

```batch
powershell -NoProfile -Command "Compress-Archive -Path 'docs\mytool\*' -DestinationPath 'docs\mytool\mytool-report.zip' -Force"
```

Bunu atlarsanız, sayfanızdan "İndir (zip)" satırını kaldırmanız yeterli.

**4. `docs/toc.yml`'de bağlayın**, mevcut `Reports` bölümünün altına:

```yaml
- name: Reports
  items:
    - name: My Tool Report
      href: report-pages/mytool.md
```

**5. Üst düzey görünürlüğü hak ediyorsa ana sayfaya bir kart ekleyin** (`docs/home.md`, "Every
report, one click away" ızgarası) — mevcut `<a class="rteu-card">` bloklarından birini kopyalayın.

## Yerelde test etme

`7-build-app.bat`/`.sh`'yi çalıştırın, ardından **`9-open-site.bat`/`.sh`**'yi — `site/index.html`'e
çift tıklamak yerine. `9-open-site`, üretilen `site/` klasörünü küçük bir yerel HTTP sunucusu
üzerinden sunar (`py -3.12 -m http.server` / `python3 -m http.server`) ve URL'yi yazdırır
(varsayılan `http://localhost:8080/`); tarayıcınızda o URL'yi açın. Bu adım önemlidir: aşağıdaki
"file:// çerçeveyi engeller" satırına bakın.

## Sık karşılaşılan sorunlar

| Belirti | Sebep | Çözüm |
|---|---|---|
| Çerçeve boş, ama "Yeni sekmede aç" sorunsuz çalışıyor | `site/index.html`'i `9-open-site`'nin yerel sunucusu yerine doğrudan (`file://...`) açtınız. Birçok tarayıcı, bir güvenlik önlemi olarak bir `file://` sayfasından `<iframe>` (ve DocFX'in kendi arama indeksini) yüklemeyi reddeder — bu, bu şablona özgü bir durum değildir. | `9-open-site.bat`/`.sh`'yi kullanın ve yazdırılan `http://localhost:8080/` URL'sini açın, ya da `dotnet docfx serve site`. |
| Çerçeve GitHub Pages'te de boş, tarayıcı konsolunda `X-Frame-Options` veya `frame-ancestors` geçen bir hata var | Çerçevelenen sayfa, çerçevelenmeyi reddeden bir başlık gönderdi. Bu şablonun kendi ürettiği hiçbir sayfa bunu yapmaz (statik HTML'dir, böyle bir başlığı yoktur) — bu yalnızca `<iframe>`'i bu deponun kendi ürettiği bir sayfa yerine *harici* bir siteye yönlendirirseniz olur. | Yalnızca bu deponun kendi ürettiği ve `site/` içinde barındırdığı sayfaları çerçeveleyin; harici araçları çerçevelemek yerine onlara bağlantı verin. |
| `7-build-app`'ten sonra `docs/<raporunuz>/index.html` açıkça var olduğu halde, yeni sayfa çerçeve içinde 404 veriyor | `docfx.json`'da o klasör için `resource` eşlemesi yok — DocFX yalnızca kendisine söylenen dosyaları kopyalar. | Yukarıdaki 1. adımdaki `{ "files": [ "<klasör>/**" ], "src": "docs", "dest": "docs/reports" }` girişini ekleyip yeniden derleyin. |
| Çerçeve *yanlış* içeriği gösteriyor, ya da neredeyse doğru görünen bir yol için 404 veriyor | Göreli yolda bir kayma — `docs/report-pages/*.md` dosyaları, `docs/*.md` kılavuz sayfalarına göre bir klasör seviyesi daha derindir, bu yüzden `reports/...` değil `../reports/...` gerekir (`docs/guide/` altındaki bir *kılavuz* sayfası da tesadüfen aynı `../reports/...`'a ihtiyaç duyar — körü körüne kopyalamayın, gerçek klasör derinliğini sayın). | `.md` dosyasının kendi yolundan `docs/reports/...`'a kadar klasör seviyelerini sayın; çalışan bir sayfayla (`docs/report-pages/unit-tests.md`) karşılaştırın. |
| `docfx build`, `reports/...` altındaki bir yol için `warning InvalidFileLink` yazdırıyor | Beklenen/zararsız — DocFX'in bağlantı doğrulayıcısı resource dosyalarını değil, yalnızca içerik belgelerini izler. Bu şablonun kendi derlemesinde doğrulanmıştır; bkz. [Sorun giderme](troubleshooting.tr.md). | Üretilen sayfayı açtığınızda dosya gerçekten çözülüyorsa görmezden gelin; yalnızca bağlantı gerçekten çalışmıyorsa araştırın. |

## Sırada

Her raporun ne gösterdiği için [Hangi rapor hangisi?](reports-explained.tr.md), ya da başka bir şey
başarısız olduysa [Sorun giderme](troubleshooting.tr.md).
