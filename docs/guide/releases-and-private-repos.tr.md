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

Pages, özel bir Free depoda çalışmadığı için **bu şablon Pages'i asla zorunlu kılmaz**. `7-build-all` + `9-open-site`
siteyi kendi diskinizden sunar (bkz. [Projenizi GitHub Pages olmadan göstermek](showing-without-pages.tr.md)),
`10-release` / CI ise üretilen bütün siteyi her sürümün içine `<proje>-<sürüm>-site.zip` olarak paketler -- ders sorumlusunun (veya
depoya erişimi olan herkesin) Pages olmadan görmesini sağlayan yöntem budur. **Herkese açık
(public)** bir depoda (ör. bu şablonun kendi `ucoruh/vs-net-core-template`'i) Pages normal şekilde
çalışır ve bunların hiçbirine ihtiyaç duymaz -- bkz. aşağıdaki "Pages dağıtım iş akışı".

## CI iş akışı ve Pages dağıtımı

`.github/workflows/ci.yml` tek bir boru hattıdır: Windows ve Linux işleri derler, test eder, her raporu ve API
dokümanını üretir (`7-build-all-<platform> --no-site`) ve platform başına artefakt yükler; macOS işi yalnızca
uygulamayı derler; `site` işi iki platformu birleştirir, MkDocs ve DocFX sitelerini üretir, bağlantıları denetler ve
siteyi yükler; `deploy-pages`, `main`'e push'ta (veya elle) `gh-pages` dalına yayınlar; `release` bir `v*` etiketinde
çalışır. Önce `github.event.repository.private` denetlenir:

- **Herkese açık depo:** Pages normal dağıtılır: `https://<siz>.github.io/<deponuz>/`.
- **Özel depo:** Pages adımı **atlanır** (`::notice` ve iş özeti nedenini söyler ve
  [Projenizi GitHub Pages olmadan göstermek](showing-without-pages.tr.md) sayfasına yönlendirir); depo değişkeni
  `PAGES_ON_PRIVATE` `true` ise atlanmaz (**Settings -> Secrets and variables -> Actions -> Variables**). Bunu GitHub Pro
  (veya Student Developer Pack) sahibi olup **Settings -> Pages**'ten Pages'i açtıktan sonra ayarlarsınız.

Her iki durumda da **sürüm** siteyi `<proje>-<sürüm>-site.zip` olarak ekler; özel depolarda sürümler asla atlanmaz.

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

## Her sürüm dosyası (yerelde ve GitHub'da aynı adlar)

```text
<proje>-<sürüm>[-<platform>[-<arch>]]-<içerik>[-<araç>].<uzantı>      (sürüm "v" olmadan; project.env'den)
```

| Dosya | Ne |
|---|---|
| `calculator-2.1.0-windows-x64-app.zip`, `-linux-x64-app.tar.gz`, `-macos-arm64-app.tar.gz` | uygulama, kendi kendine yeten (macOS: yalnız CI) |
| `calculator-2.1.0-<platform>-report-tests.zip` | birim test sonuçları (TRX + HTML) |
| `-report-coverage-reportgenerator.zip`, `-report-coverage-lcov.zip` | kod kapsaması, iki aile |
| `-report-doccoverage-reportgenerator.zip`, `-report-doccoverage-lcov.zip` | dokümantasyon kapsaması, iki aile |
| `-api-doxygen.zip`, `-api-docfx.zip` | API dokümanları (Doxygen; DocFX eksiksiz bir sitedir) |
| `calculator-2.1.0-source.zip`, `-site.zip` | etiketteki kaynak; tüm MkDocs sitesi (iki platform) |
| `ASSETS.md`, `SHA256SUMS.txt` | her dosyanın tablosu (platform, içerik, araç, site bağlantısı); sağlama toplamları |

`<platform>` `windows` veya `linux`'tur (yerel Linux ve WSL ikisi de `linux`). Windows ikilileri ve tüm HTML için `.zip`;
Linux/macOS ikilileri için `.tar.gz`. Yerelde `release/`, **bu platformun** dosyalarını ve tarafsız olanları içerir;
eksik olanı `ASSETS.md` söyler; CI iki platformu da üretir.

## `10-release`'i kullanma

```batch
10-release-windows.bat --dry-run
10-release-windows.bat
```

Linux/WSL'de: `./10-release-linux.sh --dry-run` vb. Sürüm `project.env` içindeki `VERSION`'dır (etiket `v<VERSION>`):
düzenleyin, commit'leyin, sonra yayınlayın. `--dry-run` her şeyi üretir (`7-build-all`), `release/`'i paketler, sonra
çalıştırmak yerine tam `gh release create` komutunu ve dosya listesini **yazdırır**. Betik kirli bir çalışma
ağacından gerçek sürümü reddeder; o etiketin sürümü zaten varsa (örn. CI oluşturduysa) yenisini yaratmak yerine
`gh release upload --clobber` ile ona yükler.

## İsteğe bağlı: CI sürümü

Bir etiket gönderin (`git tag v2.1.0 && git push origin v2.1.0`); `ci.yml` iki platformu ve macOS'u derler, sonra
yukarıdaki **her** dosyayı, canlı siteye ve her rapor sayfasına bağlanan notlarla GitHub Release'e ekler. Actions
dakikası harcar (üç çalıştırıcıda tam bir çalışma birkaç dakikadır); kaç dakikanız kaldığından emin değilseniz yerelde
`10-release` tercih edin (Free: özel depolarda ayda 2.000 dk).

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
