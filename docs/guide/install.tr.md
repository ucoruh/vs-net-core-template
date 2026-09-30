# Her şeyi kurma

İlk derlemeden önce bu araçlara ihtiyacınız var. **Tek bir betik hepsini kurar**: `4-install-tools-windows.bat`
veya `./4-install-tools-linux.sh`. Her aracın çalıştığını kanıtlayan bir komutu vardır (sürüm numaraları sizde
biraz farklı olabilir; komut hata vermediği sürece sorun yok).

## Windows

1. **Git**'i ([git-scm.com](https://git-scm.com/) veya `winget install Git.Git`) ve **GitHub CLI**'yi
   (`winget install GitHub.cli`, yalnızca `10-release` için gerekir) kurun. Sonra yeni bir terminal açın.
2. Paket yöneticisini bir kez kurun (terminali **Yönetici olarak** açın):

    ```batch
    3-install-package-manager-windows.bat
    ```

3. Geri kalan her şeyi kurun (.NET SDK için yönetici gerekmez; Chocolatey kurulumları isteyebilir):

    ```batch
    4-install-tools-windows.bat
    ```

    Şunları kurar: `global.json`'da sabitlenmiş .NET SDK (kullanıcı başına), Doxygen, Graphviz, lcov (`genhtml`) ve
    Windows'a özgü bir Perl, astyle, yerel dotnet araçları (ReportGenerator, DocFX) ve `requirements.txt`'teki Python
    araçları (MkDocs Material, coverxygen). Yeniden çalıştırmak güvenlidir: yalnızca eksik olanı kurar.

| Araç | Doğrulama | Örnek çıktı |
|------|-----------|--------------|
| Git | `git --version` | `git version 2.52.0.windows.1` |
| .NET SDK | `scripts\dotnet-env-windows.bat && dotnet --version` | `10.0.401` |
| Python + MkDocs | `py -3.12 -m mkdocs --version` | `mkdocs, version 1.6.1 ...` |
| coverxygen | `py -3.12 -m coverxygen --help` | kullanım metni, hata yok |
| Doxygen | `doxygen --version` | `1.9.x` veya daha yeni |
| lcov | `genhtml --version` | `genhtml: LCOV version 1.x/2.x` |
| ReportGenerator, DocFX | `dotnet tool restore` | `Restore was successful.` |
| astyle | `astyle --version` | `Artistic Style Version 3.x` |

> **Neden sabitlenmiş, kullanıcı başına bir .NET SDK?** Laboratuvar bilgisayarlarında çoğu zaman makine genelinde
> yalnızca eski bir SDK vardır ve yönetici hakkınız olmayabilir. `4-install-tools-windows.bat`, `global.json`'daki
> tam SDK'yı `%LocalAppData%\Microsoft\dotnet` altına kurar; her betik önce `scripts\dotnet-env-windows.bat`'ı
> yükler ve onu tercih eder. PATH'i elle düzenlemeniz gerekmez.

## Linux / WSL

Burada WSL **Linux'tur**: aynı `*-linux.sh` betikleri, Linux ikilileri, her dosya adında `linux`.

```bash
chmod +x *.sh scripts/*.sh        # klonladıktan sonra bir kez (zip indirmek çalıştırma iznini kaybettirir)
./4-install-tools-linux.sh        # apt paketleri (bir kez sudo ister), kullanıcı başına .NET SDK, dotnet ve pip araçları
```

Doğrulama:

```bash
. scripts/dotnet-env-linux.sh && dotnet --version   # 10.0.401
python3 -m mkdocs --version
python3 -m coverxygen --help
genhtml --version
doxygen --version
```

> **WSL ve Google Drive birlikte çalışmaz.** Depoyu `/mnt/g/My Drive/...` altında değil, normal bir Linux yoluna
> (`~/work/...`) klonlayın. Bkz. [Sorun giderme](troubleshooting.tr.md).

!!! note "WSL'in kendi `gh` girişi vardır"
    Windows'taki `gh` ve git kimlik bilgileri WSL ile **paylaşılmaz**. Özel bir depoyu WSL'de kullanacaksanız Ubuntu
    içinde `gh auth login`, ardından `gh auth setup-git` çalıştırın ve `gh auth status` ile doğrulayın; yoksa
    `git clone` parola sorarak takılır.

## İsteğe bağlı: bir IDE

Visual Studio 2022+ (".NET masaüstü geliştirme" iş yükü) veya C# Dev Kit ile VS Code. Betikleri çalıştırmak için
ikisi de gerekmez.

## Sırada

[Şablonu kullanma](use-the-template.tr.md).
