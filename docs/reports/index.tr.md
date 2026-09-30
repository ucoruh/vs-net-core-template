# Raporlar

Her rapor **iki kez** üretilir: bir kez **Windows**'ta, bir kez **Linux/WSL**'de; iki takım ayrı tutulur (derleyici
çıktısı, satır sonları ve araçlar farklı olabilir). Her tür için karşılaştırabilmeniz üzere **iki araç ailesi** vardır:

| Tür | Modern aile | Eski / yerel aile |
|---|---|---|
| Birim testleri | — | TRX + VSTest HTML günlükçüsü (`dotnet test`) |
| Kod kapsaması | ReportGenerator (cobertura) | lcov / `genhtml` (coverlet'in lcov çıktısı) |
| Dokümantasyon kapsaması | ReportGenerator (coverxygen lcov) | lcov / `genhtml` (coverxygen lcov) |
| API dokümanları | DocFX (C# yerel) | Doxygen (üç şablonda da) |

Bağımsız raporlar **bu sitenin içinde** çerçevede açılır; DocFX kendi başına bir sitedir ve yeni sekmede açılır.
Kural ve doğru/yanlış örneği: [Sitenizin içinde HTML raporu göstermek](../guide/embed-html-in-site.tr.md).
Her raporun ne gösterdiği: [Hangi rapor hangisi?](../guide/reports-explained.tr.md).

| Rapor | Windows | Linux / WSL |
|---|---|---|
| Birim testleri | [aç](windows/tests-trx.md) | [aç](linux/tests-trx.md) |
| Kod kapsaması — ReportGenerator | [aç](windows/coverage-reportgenerator.md) | [aç](linux/coverage-reportgenerator.md) |
| Kod kapsaması — lcov | [aç](windows/coverage-lcov.md) | [aç](linux/coverage-lcov.md) |
| Dok. kapsaması — ReportGenerator | [aç](windows/doccoverage-reportgenerator.md) | [aç](linux/doccoverage-reportgenerator.md) |
| Dok. kapsaması — lcov | [aç](windows/doccoverage-lcov.md) | [aç](linux/doccoverage-lcov.md) |
| API dokümanı — Doxygen | [aç](windows/api-doxygen.md) | [aç](linux/api-doxygen.md) |
| API dokümanı — DocFX | [aç](windows/api-docfx.md) | [aç](linux/api-docfx.md) |

!!! note "Bir platformda yer tutucu sayfa görünür"
    Yerel bir derleme yalnızca üzerinde derlediğiniz platformu bilir. Diğer platformun sayfaları bunu söyler; CI ikisini
    de derlediği için canlı sitede her şey vardır.
