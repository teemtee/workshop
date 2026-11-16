# Before We Begin

**Goal:** See what testing looks like with and without tmt, so you understand the problem it solves before building anything yourself.

**Prerequisites:**
- Fedora: `sudo dnf install -y tmt+all`
- Other distros: see [Install](https://tmt.readthedocs.io/en/stable/overview.html#install)


## You have a test

Say you have a simple test — it checks if `tree` is installed:

```bash
#!/bin/bash
tree --version
if [ $? -eq 0 ]; then
    echo "PASS: tree works"
    exit 0
else
    echo "FAIL: tree not found"
    exit 1
fi
```

It's just a shell script. Exit code `0` is pass, `1` is fail, anything else is error. This script is the same whether you use tmt or not — tmt doesn't change how you write tests.


## The problem

Running this test on your laptop is easy — just `./test.sh`. But what about CI?

A GitHub Actions workflow for **one distro** is simple:

```yaml
name: Test tree
on: push

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: sudo apt-get install -y tree
      - run: ./test.sh
```

This file lives in your repo as `.github/workflows/test.yml`. Every time you push code, GitHub runs the `test` job — it installs tree on an Ubuntu machine and runs your test.

Now run the same test on Ubuntu, Fedora, **and** CentOS Stream. Problem: each distro installs packages differently:

| Distro | Install command |
|--------|----------------|
| Ubuntu | `apt-get install tree` |
| Fedora | `dnf install tree` |
| CentOS Stream | `dnf install tree` |

GitHub runners only offer Ubuntu — to test on Fedora or CentOS Stream, you'd also need to configure containers and a build matrix in your workflow:

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    container: ${{ matrix.container }}
    strategy:
      fail-fast: false
      matrix:
        container:
          - ubuntu:latest
          - fedora:latest
          - quay.io/centos/centos:stream9
    steps:
      - uses: actions/checkout@v4
      - name: Install dependencies (Ubuntu)
        run: apt-get update && apt-get install -y tree
        if: matrix.container == 'ubuntu:latest'
      - name: Install dependencies (Fedora)
        run: dnf install -y tree
        if: matrix.container == 'fedora:latest'
      - name: Install dependencies (CentOS Stream)
        run: dnf install -y tree
        if: matrix.container == 'quay.io/centos/centos:stream9'
      - run: ./test.sh
```

Every distro needs its own install step. That's one package — this can quickly get out of hand.


## Now do it with tmt

Take the same test script:

```bash
#!/bin/bash
tree --version
if [ $? -eq 0 ]; then
    echo "PASS: tree works"
    exit 0
else
    echo "FAIL: tree not found"
    exit 1
fi
```

Initialize tmt and add a metadata file that declares the dependency:

```bash
tmt init
```

```yaml
# test.fmf
test: ./test.sh
require:
  - tree
```

Run everything:

```bash
tmt run
```

That's it. tmt found the test, installed tree, ran the test, and reported the result.

**Don't worry if this doesn't fully make sense yet — Lesson 1 walks through every step.**
