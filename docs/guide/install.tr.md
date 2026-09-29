# Her şeyi kurma

İlk derlemeden önce bu araçlara ihtiyacınız var. Her satırda işe yaradığını kanıtlayan komut ve bu
kılavuz yazılırken gerçekten çalıştırılıp yakalanan çıktı var (sizde sürüm numaraları farklı
olabilir -- komut hata vermediği sürece sorun değil).

## Windows

| # | Araç | Kurulum | Doğrulama | Örnek çıktı |
|---|------|---------|-----------|-------------|
| 1 | Git | [git-scm.com](https://git-scm.com/) veya `winget install Git.Git` | `git --version` | `git version 2.52.0.windows.1` |
| 2 | GitHub CLI (`gh`) | `winget install GitHub.cli` (`10-release` için gerekli) | `gh --version` | `gh version 2.90.0` |
| 3 | Chocolatey + Scoop | `3-install-package-manager.bat` | `where choco` | `%ProgramData%\Chocolatey` altında bir yol |
| 4 | .NET SDK (`global.json`'da sabitlendi) | `4-install-dotnet-sdk.bat` (kullanıcı bazlı, yönetici gerekmez) | `dotnet-env.bat && dotnet --version` | `10.0.401` |
| 5 | Astyle (kod biçimlendirici) | `4-install-astyle.bat` | `astyle --version` | `Artistic Style Version 3.6.2` |
| 6 | Python 3 | çoğu makinede zaten var, yoksa `choco install python -y` | `py -3.12 --version` | `Python 3.12.6` |
| 7 | coverxygen (Python paketi) | `4-install-coverxygen.bat` | `py -3.12 -m coverxygen --help` | hatasız kullanım metni |
| 8 | lcov (`genhtml`) | `4-install-lcov.bat` | `genhtml --version` | `genhtml: LCOV version 1.15...` |
| 9 | Doxygen + Graphviz, ReportGenerator + DocFX | `6-install-docfx-and-report-tools.bat` | `doxygen --version`, `dot -V`, `dotnet tool restore` | `1.9.7`, `dot - graphviz version 9.0.0`, `Restore was successful.` |

Bu sırayla çalıştırın (`3`, `4`/`5`/`6`'dan önce; `4`, `dotnet` çağıran her şeyden önce):

```batch
3-install-package-manager.bat
4-install-dotnet-sdk.bat
4-install-astyle.bat
4-install-coverxygen.bat
4-install-lcov.bat
6-install-docfx-and-report-tools.bat
```

Her script yeniden çalıştırılabilir (idempotent): istediğiniz zaman tekrar çalıştırın, yalnızca
eksik olanı kurar.

> **Neden makinenizde zaten olan şeyin yanına, kullanıcı bazlı, sabitlenmiş bir .NET SDK'sı daha?**
> Birçok laboratuvar/ortak bilgisayarda makine genelinde yalnızca eski bir SDK kurulu olur (ör.
> "Program Files" içinde sadece .NET 9) ve bunu değiştirecek yönetici hakkınız olmayabilir.
> `4-install-dotnet-sdk.bat`, `global.json`'daki tam SDK sürümünü kendi kullanıcı profilinize
> (`%LocalAppData%\Microsoft\dotnet`) kurar -- diğer bütün scriptler önce `dotnet-env.bat`'i
> `call` eder, bu da makine genelindeki SDK yerine sessizce bu kullanıcı bazlı SDK'yı tercih eder.
> PATH'e elle dokunmanız hiç gerekmez.

## Linux / WSL

Aynı araçlar, `apt` tabanlı kurulum, aynı script numaraları `.sh` uzantısıyla:

```bash
chmod +x *.sh   # bir kez, klonladıktan sonra: git, bir zip indirmesinde çalıştırma bitini korumaz
./3-install-package-manager.sh
./4-install-dotnet-sdk.sh
./4-install-astyle.sh
./4-install-coverxygen.sh
./4-install-lcov.sh
./6-install-docfx-and-report-tools.sh
```

Aynı şekilde doğrulayın, yalnızca `py -3.12` yerine (WSL `python3` kullanır):

```bash
. ./dotnet-env.sh && dotnet --version   # 10.0.401
astyle --version                        # Artistic Style Version 3.6.2 (veya dağıtımınızın sürümü)
python3 -m coverxygen --help
genhtml --version
doxygen --version
```

> **WSL ile Google Drive bir arada yürümez.** Klonunuz bir Windows Google Drive klasöründeyse
> (`/mnt/g/My Drive/...`), WSL buraya güvenilir biçimde erişemez (Google Drive, `G:` bağlantısı
> (mount) üzerinden bile gerçek bir yol değil, sanal/bulut bir dosya sistemidir) -- önce depoyu
> normal bir Linux yoluna kopyalayın (ör. `cp -r "/mnt/g/My Drive/.../vs-net-core-template"
> ~/vs-net-core-template`) ve her `.sh` scriptini oradan çalıştırın. Bkz.
> [Sorun giderme](troubleshooting.tr.md).

## İsteğe bağlı: bir IDE

Visual Studio 2022+ (herhangi bir sürüm, ".NET masaüstü geliştirme" iş yükü) veya
[C# Dev Kit](https://marketplace.visualstudio.com/items?itemName=ms-dotnettools.csdevkit)
eklentili VS Code, ikisi de çalışır; numaralı scriptleri çalıştırmak için hiçbiri zorunlu değildir.

## Sırada

[Şablonu kullanma](use-the-template.tr.md).
