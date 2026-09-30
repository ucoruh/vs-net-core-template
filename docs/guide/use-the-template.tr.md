# Şablonu kullanma

## 1. Kendi ÖZEL (private) deponuzu şablondan oluşturun (fork değil)

!!! warning "Use this template kullanın, fork yapmayın"
    Herkese açık bir deponun **fork'u özel yapılamaz**. **Use this template** ise özel *olabilen*, bağımsız yeni bir
    depo oluşturur. Projeniz özel bir depodan değerlendirilir.

1. <https://github.com/ucoruh/vs-net-core-template> adresini açın ve dosya listesinin sağ üstündeki yeşil
   **Use this template** düğmesine tıklayın → **Create a new repository**.
2. **Owner**: kendi hesabınız. **Repository name**: proje adınız ([Konudan projeye](from-topic-to-project.tr.md)).
3. Görünürlükte **Private** seçin. *Include all branches* işaretsiz kalsın. **Create repository**'ye tıklayın.
4. Yeni deponuzda **Settings → Collaborators → Add people** ile ders sorumlusunu (`ucoruh`) ve takım arkadaşlarınızı
   ekleyin. Bunsuz ders sorumlusu özel deponuzu ve sürümlerini göremez.

## 2. Klonlayın

```bash
git clone https://github.com/<siz>/<deponuz>.git
cd <deponuz>
```

Bu şablonda git submodule yoktur; dolayısıyla `git submodule update --init` adımı da yoktur.

## 3. Araçları kurun

[Her şeyi kurma](install.tr.md) adımını makine başına bir kez izleyin.

## 4. İlk derleme

=== "Windows"

    ```batch
    6-build-and-test-windows.bat
    7-build-all-windows.bat
    ```

=== "Linux / WSL"

    ```bash
    ./6-build-and-test-linux.sh
    ./7-build-all-linux.sh
    ```

`6-build-and-test` hızlı döngüdür (derleme + 39 birim testi, saniyeler). `7-build-all` her şeyi üretir: kapsama ile
testler, iki kapsama ailesi, iki dokümantasyon kapsama ailesi, Doxygen ve DocFX API dokümanları, uygulama,
`release/` klasörü ve site. Bir araç eksikse betik hangi kurulum adımının çalıştırılacağını söyler ve durur; hiçbir
raporu sessizce atlamaz (bkz. [Sorun giderme](troubleshooting.tr.md)).

## 5. Ürettiklerine bakın

=== "Windows"

    ```batch
    9-open-site-windows.bat
    8-run-app-windows.bat add 2 2
    ```

=== "Linux / WSL"

    ```bash
    ./9-open-site-linux.sh
    ./8-run-app-linux.sh add 2 2
    ```

`9-open-site`, `site/` klasörünü `http://localhost:8080/` adresinde sunar: her rapor ve API dokümanı ile MkDocs sitesi.
GitHub Pages yokken projenizi böyle gösterirsiniz:
[Projenizi GitHub Pages olmadan göstermek](showing-without-pages.tr.md).

## 6. Kendinizin yapın

[Konudan projeye](from-topic-to-project.tr.md) ile devam edin.
