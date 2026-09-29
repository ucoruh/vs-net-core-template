# Hangi rapor hangisi?

`7-build-app` her raporu **iki kez** üretir: bir kez modern, ekosistem-bağımsız
[ReportGenerator](https://reportgenerator.io/) aracıyla, bir kez de C/C++ ve Linux dünyasından
gelen herkesin bildiği eski/yerli (native) araçla. İkisi de aynı veriyi farklı bir görünümle sunar --
amaç da tam olarak bu karşılaştırma: gerçek iş ortamında ikisiyle de karşılaşacaksınız.

| # | Rapor | Araç | Aile | Nerede |
|---|-------|------|------|--------|
| 1 | Birim testi (unit test) sonuçları | VSTest'in yerleşik HTML günlükleyicisi (logger) | yerli | `docs/testresults/test-results.html` (+ Visual Studio'nun okuduğu ham XML: `test-results.trx`) |
| 2 | Kod kapsama (code coverage) | [ReportGenerator](https://reportgenerator.io/) (coverlet'in Cobertura çıktısını okur) | ReportGenerator | `docs/coveragereport/index.html` |
| 3 | Kod kapsama | `genhtml` (coverlet'in lcov çıktısını okur) | yerli (lcov, Linux/C++ dünyasının varsayılanı) | `docs/coverage-genhtml/index.html` |
| 4 | Belge kapsama (documentation coverage) | `genhtml` (coverxygen'in lcov çıktısını okur) | yerli | `docs/coverxygen/index.html` |
| 5 | Belge kapsama | ReportGenerator (aynı lcov dosyasını okur) | ReportGenerator | `docs/doccoverage-reportgenerator/index.html` |
| 6 | API belgeleri, ekosistem-bağımsız | [Doxygen](https://www.doxygen.nl/) | yerli (C/C++ ve Java şablonlarıyla aynı araç) | `docs/doxygen/html/index.html` |
| 7 | API referansı, C#'a özgü | [DocFX](https://dotnet.github.io/docfx/) metadata adımı | ekosistem-yerli | `site/api/` |
| 8 | Bütün site | DocFX build | -- | `site/index.html` (`9-open-site` ile açın) |

## Her biri ne anlatıyor?

**Birim testi sonuçları (yerli, #1).** Süreleriyle birlikte düz bir geçti/kaldı listesi -- bir CI
panosunun genelde önce bağlantı verdiği rapor budur. Bir test kaldığında terminale bakmadan tam
doğrulama (assertion) mesajını görmek için `test-results.html` dosyasını açın.

**Kod kapsama -- ReportGenerator (#2).** Kırmızı/sarı/yeşil kenar çubuğuyla dosya ve satır bazında
kapsama, derlemeler arası eğilim grafiği (`report_history/` altında tutulur, bkz. `.gitignore`) ve
README'nin gösterdiği küçük SVG rozetler (`assets/`). Günlük kullanım için bunu tercih edin.

**Kod kapsama -- genhtml (#3).** Aynı sayılar, lcov'un klasik dizin-ağacı görünümüyle. Daha önce bir
C/C++ projesinde `lcov`/`gcov` kullandıysanız bu size tanıdık gelecek; bir C++ projesinin üreteceği
`coverage.info` dosyasının aynısından üretilir, sadece gcov yerine coverlet yazmıştır.

**Belge kapsama (#4, #5).** "Kod ne kadar *test edildi*" değil, "genel (public) API'nin ne kadarında
XML belge yorumu (`/// <summary>...`) var" sorusunun cevabı. [coverxygen](https://github.com/psycofdj/coverxygen)
Doxygen'in XML çıktısını, kod kapsamanın da kullandığı lcov biçimine çevirir, böylece aynı iki araçla
görüntülenebilir. Bu şablonun örneğinde belge kapsama bilerek %100 değildir: `Program` sınıfı ve
`README.md`'nin anlatı metni Doxygen tarzı API yorumu taşımak zorunda değildir, bu yüzden
"belgesiz" sayılırlar -- bu bir hata değil, beklenen durumdur.

**Doxygen (#6).** `/// <summary>`, `<param>`, `<returns>` ve `<exception>` C# XML belge yorumlarını,
bir C veya C++ projesindeki `\brief`/`\param` yorumlarını işlediği gibi işler. Üç şablonun (C, Java,
C#) da aynı şekilde ürettiği tek rapor budur; C#'ın kendine ait, daha bu dile uygun bir aracı (#7)
olsa da bu yüzden faydalıdır.

**DocFX API referansı (#7).** Doğrudan derlenmiş assembly'nin XML belge dosyasından
(`CalculatorLibrary.xml`, `CalculatorLibrary.csproj` içindeki
`<GenerateDocumentationFile>true</GenerateDocumentationFile>` ile üretilir) üretilir -- profesyonel
bir .NET projesinin gerçekte yayınladığı budur (aynı yöntemle üretilen
[Microsoft'un kendi API belgeleriyle](https://learn.microsoft.com/dotnet/api/) karşılaştırın). C#
generic'lerini, nullable işaretlerini ve kalıtımı Doxygen'den daha iyi anlar.

**Site (#8).** Yukarıdakilerin hepsi, artı şu an okuduğunuz kılavuzlar, tek yerden bağlantılı. Ne
zaman ne çalıştırılır için bkz. [Günlük iş akışı](daily-workflow.tr.md).

## Neden tek bir araç seçilmiyor?

Çünkü işte seçme şansınız olmayacak. Bazı takımlar ReportGenerator'da karar kılar, bazıları C/C++
hattının hep kullandığı aracı kullanmaya devam eder, belge araçları ise daha da tutarsızdır. Aynı
sayıları ilk günden iki farklı görünümde görmek, ilerde hiçbirinin sürpriz olmaması demektir.
