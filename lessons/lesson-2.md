# Lesson 2: Dependencies, Plans, and Multiple OS Images

**Goal:** By the end, you'll know how to declare package dependencies with `require`, create a plan to control where tests run, and execute the same test across different OS images.

**Prerequisites:** Complete Lesson 1. You should have a working test under `~/test-demo/lesson-1/`.

---

## Task 1 — Set up from Lesson 1

```bash
cp -r ~/test-demo/lesson-1 ~/test-demo/lesson-2
cd ~/test-demo/lesson-2
```

Make sure everything still works:

```bash
tmt tests ls
tmt run --all -vv
```

You should see `/tests/smoke` pass.

---

## Task 2 — Write a test that needs a package

Create a test that uses `jq` (a JSON processor). Most containers don't have it pre-installed.

```bash
mkdir -p tests/json-parse
```

Write `tests/json-parse/test.sh`:

```bash
#!/bin/bash
echo '{"name": "tmt", "version": 2}' | jq '.name'
if [ $? -eq 0 ]; then
    echo "PASS: jq parsed JSON successfully"
    exit 0
else
    echo "FAIL: jq could not parse JSON"
    exit 1
fi
```

```bash
chmod +x tests/json-parse/test.sh
```

Create `tests/json-parse/main.fmf`:

```yaml
summary: Parse JSON with jq
test: ./test.sh
duration: 2m
```

**Verify:**

```bash
tmt tests ls
```

You should see both `/tests/smoke` and `/tests/json-parse`.

---

## Task 3 — Run and watch it fail

```bash
tmt run --all -vv
```

`/tests/smoke` passes but `/tests/json-parse` **fails** — `jq` isn't installed in the container.

Check the failure:

```bash
tmt run --last report -vvv
```

You'll see `jq: command not found`.

---

## Task 4 — Fix it with `require`

Edit `tests/json-parse/main.fmf`:

```yaml
summary: Parse JSON with jq
test: ./test.sh
duration: 2m
require:
  - jq
```

`require` tells tmt to install the listed packages before running this test.

Run again:

```bash
tmt run --all -vv
```

Both tests should **PASS**. tmt installed `jq` inside the container before running your test.

---

## Task 5 — Create a plan

So far you've been using `tmt run --all`, which uses defaults for everything — it discovers tests automatically, provisions a local environment, and runs. But what if you want to run tests in a container? Or on a specific OS? That's what a plan is for.

```bash
mkdir -p plans
```

Create `plans/basic.fmf`:

```yaml
summary: Run tests in a Fedora container
discover:
    how: fmf
provision:
    how: container
    image: fedora:latest
execute:
    how: tmt
```

| Block | What it answers |
|-------|-----------------|
| `discover` | "Where do I find tests?" — scan the fmf metadata tree |
| `provision` | "Where do I run them?" — a fresh Fedora container |
| `execute` | "How do I run them?" — tmt's built-in executor |

**Verify:**

```bash
tmt plans ls
```

You should see `/plans/basic`.

Now run with the plan (no `--all` needed — tmt reads the plan):

```bash
tmt run -vv
```

Same result as before, but now you control the environment explicitly.

---

## Task 6 — Run the same test on a different OS

Create a second plan. Create `plans/centos.fmf`:

```yaml
summary: Run tests on CentOS Stream 9
discover:
    how: fmf
provision:
    how: container
    image: quay.io/centos/centos:stream9
execute:
    how: tmt
```

**Verify:**

```bash
tmt plans ls
```

You should see `/plans/basic` and `/plans/centos`.

Now run both:

```bash
tmt run -vv
```

tmt runs **all** your tests under **both** plans — once on Fedora, once on CentOS. Same tests, different environments, zero changes to the test itself.

To run only the CentOS plan:

```bash
tmt run -vv plan --name /plans/centos
```

---

## What you built

```
~/test-demo/lesson-2/
├── .fmf/
│   └── version
├── plans/
│   ├── basic.fmf              <- run on Fedora
│   └── centos.fmf             <- run on CentOS Stream 9
└── tests/
    ├── smoke/
    │   ├── main.fmf
    │   └── test.sh
    └── json-parse/
        ├── main.fmf            <- require: jq
        └── test.sh
```

**New concepts in this lesson:**

| Concept | Where it lives | What it does |
|---------|---------------|--------------|
| `require` | test `main.fmf` | Package dependency — tmt installs it before the test |
| plan | `plans/*.fmf` | Controls how tests are discovered, where they run, and how they execute |
| `provision: how: container` | plan | Run tests in a container image |
| `plan --name` | CLI | Run only a specific plan |

---

## Lesson 2 checklist

- [ ] Saw a test fail because a dependency was missing
- [ ] Fixed it with `require`
- [ ] Created a plan to control the test environment
- [ ] Know the difference between `tmt run --all` and using a plan
- [ ] Ran the same tests on two different OS images
- [ ] Used `plan --name` to select a specific plan

---

**Next:** Lesson 3 — scoping plans to specific tests, the `prepare` step for environment setup, and tagging tests for filtering.
