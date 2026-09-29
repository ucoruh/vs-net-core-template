# Sürümler ve özel depolar

Ders deponuz **özel (private)** olmalı ve çoğu öğrenci ücretsiz **GitHub Free** planındadır. Bu
sayfa bunun neye izin verip neye izin vermediğini ve `10-release`'in izin vermediği tek şeyi --
özel [GitHub Pages](https://pages.github.com/)'i -- nasıl aştığını anlatır.

## Özel bir depoda GitHub Free'de ne çalışır

| Özellik | Free (özel depo) | Pro / Team / Student Pack |
|---------|-------------------|-----------------------------|
| [Releases](https://docs.github.com/repositories/releasing-projects-on-github) (etiket + ikili varlıklar (binary assets), dosya başına 2 GiB'a, 1000 varlığa kadar) | **Evet** -- yalnızca işbirlikçilere (collaborator) görünür | Evet |
| [GitHub Pages](https://docs.github.com/pages) (deponun herkese açığa yakın bir web sitesi adresi) | Özel depoda **Hayır** | **Evet** |
| GitHub Actions dakikaları | ayda 2.000 dk, 500 MB artefakt depolama | ayda 3.000 dk, 1 GB artefakt depolama |

(Bu yazı yazılırken GitHub'ın kendi belgelerine göre; güncel sayılar için
[GitHub'ın fiyatlandırma sayfasına](https://github.com/pricing) bakın.)

Pages, özel bir Free depoda çalışmadığı için **bu şablon hiç Pages'e dayanmaz**. `9-open-site`
scripti siteyi kendi diskinizden açar, `10-release` ise üretilen bütün siteyi sürümün içine
`site.zip` olarak paketler -- ders sorumlusunun (veya depoya erişimi olan herkesin) Pages olmadan
görmesini sağlayan yöntem budur.

## GitHub Student Developer Pack alın (isteğe bağlı, Pro verir)

Yine de Pages istiyorsanız (ör. ileride bir portföy parçası için), üniversite e-postanızla
[GitHub Student Developer Pack](https://education.github.com/pack)'e başvurun. Onay, GitHub
kaydınızı nasıl doğruladığına bağlı olarak dakikalar ile birkaç gün arasında sürebilir (bazen bir
öğrenci/mezun kimliği fotoğrafı istenir) -- bir teslim tarihinden önce geleceğine güvenmeyin.
Onaylandığında GitHub Pro hesabınıza otomatik uygulanır ve depo özel kalırken bile
**Settings -> Pages** altından Pages'i etkinleştirebilirsiniz.

## Ders sorumlusunu işbirlikçi olarak ekleyin

Özel bir sürüm ve özel bir deponun içeriği, erişimi olmayan kimseye görünmez. Çalışmanızın
değerlendirilebilmesi için ders sorumlusunu ekleyin:

**Settings -> Collaborators -> Add people**, dersinizin proje rehberinde belirtilen hesabı ekleyin
(ör. ders sorumlusunun GitHub kullanıcı adı); erişimin etkili olması için davetin kabul edilmesi
gerekir.

## GitHub CLI'yi (`gh`) kurun ve giriş yapın

`10-release`, her seferinde tarayıcı açmadan terminalden bir sürüm yayınlanabilsin diye web
arayüzü yerine [`gh`](https://cli.github.com/) kullanır.

```bash
# Windows
winget install GitHub.cli
# Linux/WSL
sudo apt-get install gh   # ya da bkz. https://github.com/cli/cli/blob/trunk/docs/install_linux.md

gh auth login
```

`gh auth login` sizi tarayıcı tabanlı veya token tabanlı kimlik doğrulamadan geçirir; başka bir şey
gerektiğini bilmiyorsanız `github.com`, HTTPS ve "Login with a web browser" seçin. Doğrulayın:

```bash
gh auth status
```

beklenen çıktı şuna benzer:

```
github.com
  ✓ Logged in to github.com account <kullanıcı-adınız> (keyring)
  ✓ Git operations for github.com configured to use https protocol.
  ✓ Token: gho_************************************
```

## `10-release`'i kullanma

```batch
10-release.bat --dry-run
10-release.bat v1.0.0 --dry-run
10-release.bat v1.0.0
```

Linux/WSL'de: `./10-release.sh --dry-run` vb. `--dry-run`, her şeyi derler ve paketler --
`7-build-app`'i çalıştırır, Linux/macOS/Windows için kendi kendine yeten (self-contained) ikilileri
yayınlar, her raporu ^(her iki aile -- bkz. [Hangi rapor hangisi?](reports-explained.tr.md)^),
Doxygen çıktısını ve bütün DocFX sitesini `release/site.zip` olarak paketler -- sonra bunu
çalıştırmak yerine tam `gh release create` komutunu ve bütün varlık listesini **yazdırır**. Hiçbir
şey yayınlanmaz. Yazdırılandan memnun kaldığınızda `--dry-run`'ı kaldırın.

Açık bir sürüm argümanı verilmezse script, depo kökündeki `VERSION` dosyasını (`0.1.0` gibi tek
satırlık) okur; bir sonraki sürümünüz için bu dosyayı güncelleyin. Script, kirli (uncommitted
değişiklikli) bir çalışma ağacından gerçek bir sürüm yayınlamayı reddeder -- bir sürüm her zaman
kodun tek, kesin, commit'lenmiş bir durumuna karşılık gelmelidir (`--dry-run` bu kontrolü atlar,
böylece çalışma sırasında paketlemeyi prova edebilirsiniz).

`release/site.zip`'in içinde ne var: bütün üretilmiş site, kendi kendine yeten -- herhangi bir
yere açın (unzip) ve `index.html`'i açın; içindeki her rapor ve API referans bağlantısı, bir web
sunucusu olmadan çalışan göreli bir bağlantıdır.

## İsteğe bağlı: Actions sürüm iş akışı

`.github/workflows/release.yml`, aynı yayınlamayı yapmanın **elle tetiklenen**, alternatif bir
yolu -- `workflow_dispatch` ile ya da bir `v*` etiketi push ederek tetiklenir -- `10-release`'i
yerelde çalıştırmak istemiyorsanız işinize yarar, bedeli Actions dakikalarıdır (tam bir derleme +
yayınlama + paketleme koşusu genelde aylık kotanızdan birkaç dakika harcar; günlük
`build_check_ubuntu_windows.yml` iş akışı bunu tam da bu bütçeyi yemesin diye her push'ta **değil**,
yalnızca istek/etiket üzerine çalıştırır). Kaç dakikanız kaldığından emin değilseniz yerelde
`10-release`'i tercih edin.

## Sürüm sorun giderme

| Belirti | Neden | Çözüm |
|---------|-------|-------|
| `gh release create`, `HTTP 404` ile başarısız | Yanlış depo algılandı, ya da sahibi olmadığınız özel bir depoda işbirlikçi değilsiniz | Klonlanan depo klasörünün içinden çalıştırın; `gh repo view`'ın doğru depoyu gösterdiğini doğrulayın |
| `gh release create`, `HTTP 403` ile başarısız | Kimlik doğrulanmamış, ya da token'da `repo` kapsamı eksik | Tekrar `gh auth login`; ince taneli (fine-grained) bir PAT için bu depoda *Contents: Read and write* iznine sahip olduğundan emin olun |
| `gh auth login`'den sonra bile `gh: not logged in` | Beklenenden farklı bir `gh` host/hesabına giriş yapılmış | Hangi hesabın etkin olduğunu görmek için `gh auth status`; birden fazla hesabınız varsa `gh auth switch` |
| Yükleme, varlık çok büyük mesajıyla başarısız | Tek bir varlık GitHub'ın 2 GiB sınırını aşıyor | Bu şablonun varlıklarıyla olmamalı; olursa `publish/`'in kazayla budanmadan bırakılmadığını (ör. hata ayıklama sembolleri) kontrol edin |
| Ders sorumlusu sürümü göremediğini söylüyor | Henüz işbirlikçi olarak eklenmedi, ya da davet kabul edilmedi | Yukarıdaki "Ders sorumlusunu işbirlikçi olarak ekleyin" bölümüne bakın |

## Sırada

Sorun `gh` değil de bir scriptin kendisiyse bkz. [Sorun giderme](troubleshooting.tr.md).
