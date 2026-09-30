---
title: Anasayfa
hide:
  - toc
---

<div class="rteu-hero" markdown>

# Calculator — eksiksiz bir .NET ders projesi şablonu

<p class="lead">Dönem projenize başlayacağınız bir C# / .NET çözümü: sınıf kütüphanesi, ince bir konsol uygulaması,
xUnit testleri ve <strong>her rapor iki ailede yan yana</strong> (ReportGenerator ve daha eski, yerel araçlar):
<strong>Windows</strong> ve <strong>Linux</strong> için ayrı ayrı üretilir; Doxygen ve DocFX API dokümanları, tek site ve
tek komutla yerel ve CI/CD sürüm paketleme.</p>

<div class="rteu-badges" markdown>

[![CI](https://github.com/ucoruh/vs-net-core-template/actions/workflows/ci.yml/badge.svg)](https://github.com/ucoruh/vs-net-core-template/actions/workflows/ci.yml)
[![GitHub release](https://badgen.net/github/release/ucoruh/vs-net-core-template)](https://github.com/ucoruh/vs-net-core-template/releases/latest)
[![License: MIT](https://badgen.net/github/license/ucoruh/vs-net-core-template)](https://github.com/ucoruh/vs-net-core-template/blob/main/LICENSE)
![Combined coverage](assets/badge_combined.svg)
![Branch coverage](assets/badge_branchcoverage.svg)
![Line coverage](assets/badge_linecoverage.svg)
![Method coverage](assets/badge_methodcoverage.svg)
![Doc coverage](assets/badge_doccoverage.svg)

</div>

<a class="md-button md-button--primary" href="https://github.com/ucoruh/vs-net-core-template/releases/latest">:material-download: Son sürümü indir</a>
<a class="md-button" href="guide/use-the-template/">Projenize başlayın</a>

</div>

## Her rapor, platform başına

Windows ve Linux/WSL sonuçları **ayrı** üretilir ve ayrı tutulur (farklı olabilirler). Bir platform seçin:

<div class="grid cards" markdown>

- :fontawesome-brands-windows: **Windows**

    ---

    [Birim testleri](reports/windows/tests-trx.md) ·
    [Kapsama — ReportGenerator](reports/windows/coverage-reportgenerator.md) ·
    [Kapsama — lcov](reports/windows/coverage-lcov.md) ·
    [Dok. kapsaması — ReportGenerator](reports/windows/doccoverage-reportgenerator.md) ·
    [Dok. kapsaması — lcov](reports/windows/doccoverage-lcov.md) ·
    [Doxygen](reports/windows/api-doxygen.md) ·
    [DocFX](reports/windows/api-docfx.md)

- :fontawesome-brands-linux: **Linux / WSL**

    ---

    [Birim testleri](reports/linux/tests-trx.md) ·
    [Kapsama — ReportGenerator](reports/linux/coverage-reportgenerator.md) ·
    [Kapsama — lcov](reports/linux/coverage-lcov.md) ·
    [Dok. kapsaması — ReportGenerator](reports/linux/doccoverage-reportgenerator.md) ·
    [Dok. kapsaması — lcov](reports/linux/doccoverage-lcov.md) ·
    [Doxygen](reports/linux/api-doxygen.md) ·
    [DocFX](reports/linux/api-docfx.md)

</div>

## Burada neler var

<div class="grid cards" markdown>

- :material-book-open-variant: **Kılavuzlar**

    ---

    Kurulum, şablonu kullanma, konudan projeye, günlük iş akışı, projenizi GitHub Pages olmadan göstermek, sorun giderme.

    [:octicons-arrow-right-24: Buradan başlayın](guide/install.md)

- :material-file-question: **Hangi rapor hangisi?**

    ---

    Her raporu, ne gösterdiğini ve iki ailenin nasıl ayrıştığını anlatan tek sayfa.

    [:octicons-arrow-right-24: Okuyun](guide/reports-explained.tr.md)

- :material-api: **API dokümanları**

    ---

    Doxygen (burada çerçevede) ve DocFX (kendi başına eksiksiz bir site, yeni sekmede), iki platform için.

    [:octicons-arrow-right-24: API dokümanları](api/index.md)

- :material-package-variant: **İndirmeler**

    ---

    Her sürüm dosyası: uygulamalar, raporlar, API dokümanları, site, kaynak, sağlama toplamları.

    [:octicons-arrow-right-24: İndirmeler](downloads.md)

- :material-projector-screen: **GitHub Pages olmadan gösterin**

    ---

    GitHub Free'de özel bir depo Pages kullanamaz: her şeyi yerelde üretin ve gösterin.

    [:octicons-arrow-right-24: Sunum kontrol listesi](guide/showing-without-pages.tr.md)

</div>

## Hızlı başlangıç

=== "Windows"

    ```batch
    4-install-tools-windows.bat
    7-build-all-windows.bat
    9-open-site-windows.bat
    ```

=== "Linux / WSL"

    ```bash
    chmod +x *.sh scripts/*.sh
    ./4-install-tools-linux.sh
    ./7-build-all-linux.sh
    ./9-open-site-linux.sh
    ```

`9-open-site` siteyi küçük bir yerel HTTP sunucusunda sunar ve adresi yazdırır; `site/index.html`'e çift tıklamak yerine
o adresi açın, böylece rapor çerçeveleri yüklenir.
