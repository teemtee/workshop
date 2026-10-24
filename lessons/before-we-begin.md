# Before We Begin

**Goal:** See what testing looks like with and without tmt, so you understand the problem it solves before building anything yourself.

**Prerequisites:**
- Fedora/RHEL/CentOS: `sudo dnf install -y tmt+all` — installs tmt with all optional plugins (container provisioning, HTML reports, etc.)

---

## You have a test

Say you have a simple test — it checks if curl works:

```bash
#!/bin/bash
curl --version
if [ $? -eq 0 ]; then
    echo "PASS: curl works"
    exit 0
else
    echo "FAIL: curl not found"
    exit 1
fi
```

It's just a shell script. Exit code `0` means pass, non-zero means fail. This script is the same whether you use tmt or not — tmt doesn't change how you write tests.

---

## The problem

Running this test on your laptop is easy — just `./test.sh`. But what about CI?

A GitHub Actions workflow for **one distro** is simple:

```yaml
name: Test curl
on: push

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - run: apt install -y curl
      - run: ./test.sh
```

This file lives in your repo as `.github/workflows/test.yml`. Every time you push code, GitHub runs the `test` job — it installs curl on an Ubuntu machine and runs your test.

Now run the same test on Ubuntu, Fedora, **and** CentOS. Problem: each distro installs packages differently:

| Distro | Install command |
|--------|----------------|
| Ubuntu | `apt install curl` |
| Fedora | `dnf install curl` |
| CentOS | `yum install curl` |

So your CI file needs:

```yaml
- run: |
    if command -v apt; then
      apt install -y curl
    elif command -v dnf; then
      dnf install -y curl
    fi
```

That's just **one** package. Imagine 10 packages across 5 distros — your CI file becomes a wall of if/else.

---

## Now do it with tmt

Take the same curl test script:

```bash
#!/bin/bash
curl --version
if [ $? -eq 0 ]; then
    echo "PASS: curl works"
    exit 0
else
    echo "FAIL: curl not found"
    exit 1
fi
```

Initialize tmt and add a metadata file that declares the dependency:

```bash
tmt init
```

```yaml
# main.fmf
summary: Check that curl works
test: ./test.sh
require:
  - curl
```

Run everything:

```bash
tmt run --all
```

That's it. tmt found the test, installed curl, ran the test, and reported the result.

**Don't worry if this doesn't fully make sense yet — Lesson 1 walks through every step.**

---

