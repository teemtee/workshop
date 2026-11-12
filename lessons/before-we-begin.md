# Before We Begin

**Goal:** See what testing looks like with and without tmt, so you understand the problem it solves before building anything yourself.

**Prerequisites:**
- Fedora/RHEL/CentOS: `sudo dnf install -y tmt+all` — installs tmt with all optional plugins (container provisioning, HTML reports, etc.)


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

It's just a shell script. Exit code `0` is pass, `1` is fail, anything else is error. This script is the same whether you use tmt or not — tmt doesn't change how you write tests.


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
      - uses: actions/checkout@v4
      - run: sudo apt-get install -y curl
      - run: ./test.sh
```

This file lives in your repo as `.github/workflows/test.yml`. Every time you push code, GitHub runs the `test` job — it installs curl on an Ubuntu machine and runs your test.

Now run the same test on Ubuntu, Fedora, **and** CentOS Stream. Problem: each distro installs packages differently:

| Distro | Install command |
|--------|----------------|
| Ubuntu | `apt-get install curl` |
| Fedora | `dnf install curl` |
| CentOS Stream | `dnf install curl` |

GitHub runners only offer Ubuntu — to test on Fedora or CentOS Stream, you'd also need to configure containers and a build matrix in your workflow.

So your CI file needs:

```yaml
- run: |
    if command -v apt-get > /dev/null; then
      apt-get update && apt-get install -y curl
    elif command -v dnf > /dev/null; then
      dnf install -y curl
    fi
```

And even this isn't enough — CentOS Stream ships `curl-minimal` which conflicts with `curl`, so `dnf install curl` fails unless you add a special flag `dnf install -y --allowerasing curl`. You'd only find out when CI breaks.

This can quickly get out of hand.


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
tmt run
```

That's it. tmt found the test, installed curl, ran the test, and reported the result.

**Don't worry if this doesn't fully make sense yet — Lesson 1 walks through every step.**

