# Hangi rapor hangisi?

`7-build-all` **her raporu iki kez** üretir: modern, ekosistemler arası araçla (ReportGenerator) ve daha eski / yerel
araçla; böylece aynı sayıları iki biçimde görürsünüz. Ve bunları **platform başına** üretir: bir kez Windows'ta, bir
kez Linux/WSL'de, ayrı tutulur (farklı olabilirler).

| # | Rapor | Modern aile | Yerel / eski aile | Klasör (`reports/<platform>/...`) |
|---|---|---|---|---|
| 1 | Birim testleri | - | `dotnet test` TRX + VSTest HTML günlükçüsü | `tests-trx/` |
| 2 | Kod kapsaması | ReportGenerator (cobertura) | - | `coverage-reportgenerator/` |
| 3 | Kod kapsaması | - | lcov `genhtml` (coverlet'in lcov çıktısı) | `coverage-lcov/` |
| 4 | Dokümantasyon kapsaması | ReportGenerator (coverxygen lcov) | - | `doccoverage-reportgenerator/` |
| 5 | Dokümantasyon kapsaması | - | lcov `genhtml` (aynı lcov dosyası) | `doccoverage-lcov/` |
| 6 | API dokümanı | - | Doxygen (üç şablonda aynı araç) | `api-doxygen/` |
| 7 | API dokümanı | DocFX (C# yerel) | - | `api-docfx/` (ayrıca `site-native/`) |
| 8 | Ana site | MkDocs Material | - | `site/` |

Sitede 1-6 numaralılar çerçevede gösterilir; 7 numara kendi başına eksiksiz bir sitedir ve bağlantıyla (yeni sekmede)
açılır. Bkz. [Sitenizin içinde HTML raporu göstermek](embed-html-in-site.tr.md).

## Her birini nasıl okumalı

**Birim test sonuçları (#1).** Süreli geçti/kaldı listesi. Bir test kaldığında, terminale dokunmadan tam doğrulama
mesajını görmek için açın.

**Kod kapsaması, ReportGenerator (#2).** Dosya ve satır bazında kapsama, kırmızı/yeşil kenar, derlemeler arası eğilim
grafiği (geçmiş `report_history/<platform>/` içinde) ve `docs/assets/` altındaki küçük SVG rozetler. Günlük iş için
bunu kullanın.

**Kod kapsaması, lcov (#3).** Aynı sayılar, lcov'un klasik dizin ağacı görünümünde; bir C++ projesinin ürettiği
`coverage.info` ile aynı dosyadan, yalnızca gcov yerine coverlet yazmış.

**Dokümantasyon kapsaması (#4, #5).** "Kodun ne kadarı test edildi" değil, "genel API'nin ne kadarında XML doküman
yorumu (`/// <summary>`) var". [coverxygen](https://github.com/psycofdj/coverxygen) Doxygen'in XML çıktısını kod
kapsamasının kullandığı lcov biçimine çevirir, böylece iki araçtan biri de çizebilir. Örnekte kasıtlı olarak %100 değildir.

**Doxygen (#6).** C# XML doküman yorumlarını, C veya C++'taki `\brief`/`\param` yorumlarını çizdiği gibi çizer: her
şablonun aynı biçimde ürettiği tek API dokümanı.

**DocFX (#7).** Derlemenin XML doküman dosyasından üretilir; profesyonel bir .NET projesinin yayınladığı budur.
Generic'leri, nullable ek açıklamalarını ve kalıtımı Doxygen'den iyi anlar.

## Neden platform başına?

Kapsama ve test sonuçları Windows ile Linux arasında farklılaşabilir (yol işleme, satır sonları, platforma özgü kod,
farklı araç sürümleri). Her klasör ve dosya adında platformu tutmak, bir platformun diğerinin üzerine sessizce yazması
yerine farkı görünür kılar.

## Neden tek bir araç seçmiyoruz?

Çünkü iş hayatında seçme şansınız olmayacak. Aynı sayıları ilk günden iki biçimde görmek, hiçbir stilin sonradan
sürpriz olmamasını sağlar.
