# Bir proje konusundan kendi projenize

Bu bölüm, örnek `Calculator*` projesini gerçek bir projeye dönüştürme adımlarını, ders proje
rehberinde sık görülen bir konu olan **"Kütüphane Yönetim Sistemi" (Library Management System)**
örneği üzerinden anlatır. Her yerde kendi konunuzun adını kullanın.

## Kontrol listesi

- [ ] Kısa, PascalCase bir proje adı seçin (`LibraryCatalog`, "Kütüphane Yönetim Sistemi" değil).
- [ ] Çözümü (solution), üç proje klasörünü ve `.csproj` dosyalarını yeniden adlandırın.
- [ ] Her `.csproj`'daki kök ad alanını (`RootNamespace`) ve her `namespace` bloğunu yeniden adlandırın.
- [ ] `Doxyfile`'ın `PROJECT_NAME`/`PROJECT_BRIEF`'ini, `docfx.json`'ın metadata `src`'ini ve
      `toc.yml`/`docs/toc.yml` başlıklarını güncelleyin.
- [ ] `README.md`'yi kendi projenizin açıklamasıyla değiştirin (bu, sitenin ana sayfası olan
      `docs/index.md` olur -- bkz. [Hangi rapor hangisi?](reports-explained.tr.md)).
- [ ] Her yeni sınıf için **önce** testleri yazın; tıpkı `CalculatorCliTests.cs`'nin
      `CalculatorCli`'ye güvenmeden önce onu test etmesi gibi.
- [ ] "Ayrıştırma (parsing) kütüphanede yaşar, `Program.cs`'de değil" şeklini koruyun (aşağıda),
      böylece kendi komut satırı işlemeniz de test edilebilir kalır.
- [ ] Her yeniden adlandırma adımından sonra `7-build-app`'i çalıştırın -- bütün değişiklikleri
      birikte yapıp sonunda "umarım çalışır" demeyin.

## Adım adım ("LibraryCatalog" örneği)

**1. Klasörleri ve dosyaları yeniden adlandırın.**

```bash
git mv CalculatorLibrary LibraryCatalog
git mv CalculatorLibrary/CalculatorLibrary.csproj LibraryCatalog/LibraryCatalog.csproj
git mv CalculatorLibrary/Calculator.cs LibraryCatalog/Book.cs                # ya da ilk gerçek sınıfınız
git mv CalculatorLibrary/CalculatorCli.cs LibraryCatalog/LibraryCatalogCli.cs

git mv CalculatorApp CalculatorApp.old && git mv CalculatorApp.old LibraryCatalogApp
git mv LibraryCatalogApp/CalculatorApp.csproj LibraryCatalogApp/LibraryCatalogApp.csproj

git mv CalculatorLibrary.Tests LibraryCatalog.Tests
git mv LibraryCatalog.Tests/CalculatorLibrary.Tests.csproj LibraryCatalog.Tests/LibraryCatalog.Tests.csproj
git mv LibraryCatalog.Tests/CalculatorTests.cs LibraryCatalog.Tests/BookTests.cs
git mv LibraryCatalog.Tests/CalculatorCliTests.cs LibraryCatalog.Tests/LibraryCatalogCliTests.cs
```

(`git mv CalculatorApp CalculatorApp.old && git mv ... LibraryCatalogApp`, yalnızca uygulama/kütüphane
adlandırması farklıyken Windows'un büyük/küçük harf duyarsız dosya sistemini aşmak içindir; isimler
gerçekten farklıysa yukarıdaki gibi düz bir `git mv A B` genelde yeterlidir.)

**2. Çözüm (solution) dosyasını güncelleyin.** `CalculatorLibrary.sln`'i bir metin düzenleyicide (veya
`dotnet sln` ile) açın, üç proje adını/yolunu değiştirin, sonra dosyayı yeniden adlandırın:

```bash
git mv CalculatorLibrary.sln LibraryCatalog.sln
```

```bash
dotnet sln LibraryCatalog.sln remove LibraryCatalog/LibraryCatalog.csproj 2>/dev/null || true
dotnet sln LibraryCatalog.sln add LibraryCatalog/LibraryCatalog.csproj LibraryCatalogApp/LibraryCatalogApp.csproj LibraryCatalog.Tests/LibraryCatalog.Tests.csproj
```

(Pratikte en basiti: `.sln`'i silip `dotnet new sln -n LibraryCatalog` ile yeniden oluşturmak,
ardından üç `dotnet sln add` çağrısı yapmak -- GUID'leri elle düzenlemekten daha hızlı.)

**3. Ad alanını (namespace) her yerde değiştirin.** Bu şablondaki her `.cs` dosyası içeriğini
`namespace CalculatorLibrary { ... }` / `namespace CalculatorApp { ... }` /
`namespace CalculatorLibrary.Tests { ... }` içine sarar. `*.cs` dosyalarında proje geneli bir
bul-değiştir yapın (`CalculatorLibrary` -> `LibraryCatalog`, `CalculatorApp` -> `LibraryCatalogApp`)
ve her `.csproj`'daki `<RootNamespace>`'i buna göre ayarlayın.

**4. Örnek sınıfı değiştirin.** (`Calculator.cs`'den yeniden adlandırılan) `Book.cs` ilk gerçek
sınıfınız olur -- aritmetik metodları silin, kendi metodlarınızı ekleyin ve her genel (public) üyeye
örnekteki gibi aynı türden XML belge yorumu (`<summary>`, `<param>`, `<returns>`) verin, böylece
Doxygen ve DocFX çalışmaya devam eder.

**5. Ayrıştırmayı kütüphanede tutun.** (`CalculatorCli.cs`'den yeniden adlandırılan)
`LibraryCatalogCli.cs`, korunması gereken desendir: ayrıştırıp çalıştıran, sonucu string olarak
döndüren, hatalı girdide açık mesajlı `ArgumentException` fırlatan `Run(string[] args)` metodlu statik
bir sınıf. `Program.cs`, onu çağırıp sonucu yazdıran ince bir kabuk olarak kalır -- ayrıştırma
mantığını uygulamayı bir süreç olarak başlatmadan birim testine tabi tutulabilir kılan ve
`Program.cs`'in kendisini test edilmeye değer mantıktan arındıran şey budur.

**6. Önce testleri yazın.** Her yeni genel metot için: bir normal durum testi, bir sınır durumu
(boundary case) testi (boş girdi, sıfır, alanınız için mantıklı en küçük/en büyük değer), bir
geçersiz girdi testi. `CalculatorTests.cs`/`CalculatorCliTests.cs` şekli gösterir
(normal/sınır durumlar için `[Theory]` + `[InlineData]`, geçersiz girdi için `Assert.Throws<T>`).

**7. Belgeleri güncelleyin.**

- `Doxyfile`: `PROJECT_NAME`, `PROJECT_BRIEF` ve `INPUT` listesi (klasör adları değişti).
- `docfx.json`: `metadata[0].src[0].src` yolu (`CalculatorLibrary` yerine `LibraryCatalog`).
- `toc.yml` / `docs/toc.yml`: hâlâ "Calculator" diyen sayfa başlıkları.
- `README.md`: projenizin gerçek açıklaması (sitenin ana sayfası olur).

**8. Yeniden derleyin ve kontrol edin.**

```batch
7-build-app.bat
9-open-site.bat
```

Şunları doğrulayın: derleme 0 uyarıyla geçiyor, bütün testleriniz geçiyor, `site/api/` altındaki API
referansı sizin sınıflarınızı listeliyor (`Calculator` değil) ve kapsama beklediğiniz yerde.

## "Kapsamayı korumak" pratikte ne demek?

Örneğin %100 satır kapsamasının, test yazmadan kod eklediğiniz için sessizce %60'a düşmesine izin
vermeyin. Her yeni sınıftan sonra `7-build-app`'i çalıştırın ve bir sonrakine geçmeden önce
`docs/coveragereport/index.html`'e bakın
([Hangi rapor hangisi?](reports-explained.tr.md)) -- eksik testi hemen yazmak, sonradan on tane
test edilmemiş metodun amacını yeniden hatırlamaya çalışmaktan çok daha kolaydır.

## Sırada

[Günlük iş akışı](daily-workflow.tr.md).
