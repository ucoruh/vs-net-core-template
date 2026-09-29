# Use this template

## 1. Create your own repository from it

On GitHub, open [`ucoruh/vs-net-core-template`](https://github.com/ucoruh/vs-net-core-template) and
click **Use this template -> Create a new repository**. Name it after your project (see
[From topic to project](from-topic-to-project.en.md) for the naming convention your course expects).
This creates a normal, independent repository -- not a fork -- with its own history starting from
this template's current state. Make it **private** and add your instructor as a collaborator (see
[Releases & private repositories](releases-and-private-repos.en.md)).

## 2. Clone it

```bash
git clone https://github.com/<you>/<your-repo>.git
cd <your-repo>
```

There is no git submodule in this template (unlike the C++ template), so there is no
`git submodule update --init` step here.

## 3. Install the toolchain

Follow [Install everything](install.en.md) once per machine.

## 4. First build

```batch
7-build-app.bat
```

on Linux/WSL:

```bash
./7-build-app.sh
```

Expect this to take under a minute on a warm NuGet cache. It restores, builds, runs the 39 sample
tests with coverage, generates Doxygen, both code-coverage reports, both documentation-coverage
reports, and the DocFX site. If anything is missing, the script tells you exactly which
`4-install-*`/`6-install-*` script to run and stops -- it does not silently skip a report (see
[Troubleshooting](troubleshooting.en.md) if a step fails).

## 5. Look at what it built

```batch
9-open-site.bat
```

opens `site/index.html` -- the DocFX site, with the API reference, every report and this guide
linked from its navigation. Or run the sample app directly:

```batch
8-run-app.bat
8-run-app.bat add 2 2
```

## 6. Make it yours

Continue with [From topic to project](from-topic-to-project.en.md).
