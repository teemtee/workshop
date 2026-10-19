# Before We Begin

**Goal:** See what testing looks like with and without tmt, so you understand the problem it solves before building anything yourself.

**Prerequisites:**
- Fedora/RHEL/CentOS: `sudo dnf install -y tmt+all`

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

To actually run this test, you need to:

1. Make sure `curl` is installed on the machine
2. Run the script yourself
3. Check the output

That's fine for one test on one machine. But now imagine:
- You have 200 tests instead of 1
- You need to run them on Fedora, CentOS, *and* RHEL
- A new team member joins and asks "how do I run the tests?"
- You need results in a format CI can consume

Every team does it differently. Nothing is discoverable. Nothing is portable. This is the problem tmt solves.

---

## Now do it with tmt

Let's do the **same test** with tmt:

```bash
mkdir -p ~/test-demo/with-tmt
cd ~/test-demo/with-tmt
git init
tmt init
```

Create the same curl test script:

```bash
mkdir -p tests/curl-check
cat <<'EOF' > tests/curl-check/test.sh
#!/bin/bash
curl --version
if [ $? -eq 0 ]; then
    echo "PASS: curl works"
    exit 0
else
    echo "FAIL: curl not found"
    exit 1
fi
EOF
chmod +x tests/curl-check/test.sh
```

Add metadata — one small file that declares the dependency:

```yaml
# tests/curl-check/main.fmf
summary: Check that curl works
test: ./test.sh
require:
  - curl
```

Add a plan — tells tmt how to run it:

```yaml
# plans/smoke.fmf
summary: Smoke tests
discover:
    how: fmf
provision:
    how: container
    image: fedora:latest
execute:
    how: tmt
```

Run everything:

```bash
tmt run
```

That's it. tmt found the test, spun up a container, installed curl, ran the test, and reported the result. No manual steps.

**Don't worry if the YAML files don't make sense yet — Lesson 1 breaks down every piece.**

---

## What you just saw

Let's step back and name the moving parts before we build them ourselves.

In the "without tmt" approach, **you** were the glue — you installed dependencies, ran the script, captured output, and would repeat all of that on every machine. Nothing was written down except the test itself.

In the "with tmt" approach, three pieces replaced all of that manual work:

1. **A test script** (`tests/curl-check/test.sh`) — the same shell script as before. tmt doesn't change how you write tests. It only cares about the exit code: `0` means pass, non-zero means fail.

2. **Test metadata** (`tests/curl-check/main.fmf`) — a small YAML file that sits next to the script and declares two things: *what to run* (`test: ./test.sh`) and *what it needs* (`require: curl`). This is how tmt knows about your test and its dependencies without you installing anything manually.

3. **A plan** (`plans/smoke.fmf`) — the orchestrator. It answers three questions:
   - **discover** — where to find tests (scan the fmf metadata tree)
   - **provision** — where to run them (a fresh Fedora container)
   - **execute** — how to run them (tmt's built-in executor)

When you typed `tmt run`, tmt read the plan, found the test through its metadata, spun up a container, installed `curl` because the metadata said to, ran the script, and reported the result. One command replaced four manual steps.

Lesson 1 builds these three pieces from scratch so you understand exactly what each one does and why it's needed.
