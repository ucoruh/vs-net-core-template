# Şablonu kullanma

## 1. Kendi deponuzu buradan oluşturun

GitHub'da [`ucoruh/vs-net-core-template`](https://github.com/ucoruh/vs-net-core-template) sayfasını
açın ve **Use this template -> Create a new repository**'ye tıklayın. Projenize uygun bir isim verin
(dersinizin beklediği adlandırma kuralı için bkz. [Konudan projeye](from-topic-to-project.tr.md)).
Bu işlem fork değil, bu şablonun o anki durumundan başlayan, kendi geçmişine sahip normal ve bağımsız
bir depo oluşturur. Deponuzu **özel (private)** yapın ve ders sorumlusunu işbirlikçi (collaborator)
olarak ekleyin (bkz. [Sürümler ve özel depolar](releases-and-private-repos.tr.md)).

## 2. Klonlayın

```bash
git clone https://github.com/<siz>/<deponuz>.git
cd <deponuz>
```

Bu şablonda (C++ şablonunun aksine) git alt modülü (submodule) yok, dolayısıyla burada
`git submodule update --init` adımı da yok.

## 3. Araç zincirini kurun

Makine başına bir kez [Her şeyi kurma](install.tr.md) adımlarını izleyin.

## 4. İlk derleme

```batch
7-build-app.bat
```

Linux/WSL'de:

```bash
./7-build-app.sh
```

NuGet önbelleği doluysa bunun bir dakikadan az sürmesini bekleyin. Geri yükler (restore), derler,
39 örnek testi kapsama (coverage) ile çalıştırır, Doxygen'i, her iki kod-kapsama raporunu, her iki
belge-kapsama raporunu ve DocFX sitesini üretir. Bir şey eksikse script tam olarak hangi
`4-install-*`/`6-install-*` scriptini çalıştırmanız gerektiğini söyler ve durur -- bir raporu
sessizce atlamaz (bir adım başarısız olursa bkz. [Sorun giderme](troubleshooting.tr.md)).

## 5. Ürettiğine bakın

```batch
9-open-site.bat
```

`site/index.html`'i açar -- API referansı, her rapor ve bu kılavuzun gezinme çubuğundan bağlantılı
olduğu DocFX sitesi. Ya da örnek uygulamayı doğrudan çalıştırın:

```batch
8-run-app.bat
8-run-app.bat add 2 2
```

## 6. Kendinize göre uyarlayın

[Konudan projeye](from-topic-to-project.tr.md) ile devam edin.
