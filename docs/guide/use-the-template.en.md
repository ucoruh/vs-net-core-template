# Use this template

## 1. Create your own PRIVATE repository from it (not a fork)

!!! warning "Use this template — do not fork"
    A fork of a public repository **cannot be made private**. **Use this template** creates a brand-new,
    independent repository that *can* be private. Your project is graded from a private repository.

1. Open <https://github.com/ucoruh/vs-net-core-template> and click the green **Use this template** button
   (top right of the file list) → **Create a new repository**.
2. **Owner**: your own account. **Repository name**: your project name (see
   [From topic to project](from-topic-to-project.en.md)).
3. Under visibility choose **Private**. Leave *Include all branches* unchecked. Click **Create repository**.
4. In your new repository open **Settings → Collaborators → Add people** and add your instructor
   (`ucoruh`) and your team mates. Without this the instructor cannot see your private repository or its releases.

## 2. Clone it

```bash
git clone https://github.com/<you>/<your-repo>.git
cd <your-repo>
```

There is no git submodule in this template, so there is no `git submodule update --init` step.

## 3. Install the toolchain

Follow [Install everything](install.en.md) once per machine.

## 4. First build

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

`6-build-and-test` is the fast loop (build + the 39 unit tests, seconds). `7-build-all` builds everything: tests
with coverage, both coverage families, both documentation-coverage families, Doxygen and DocFX API docs, the app,
the `release/` folder and the site. If a tool is missing, the script says which install step to run and stops; it
never silently skips a report (see [Troubleshooting](troubleshooting.en.md)).

## 5. Look at what it built

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

`9-open-site` serves `site/` on `http://localhost:8080/` — the MkDocs site with every report and the API docs.
This is also how you show your project when GitHub Pages is not available:
[Showing your project without GitHub Pages](showing-without-pages.en.md).

## 6. Make it yours

Continue with [From topic to project](from-topic-to-project.en.md).
