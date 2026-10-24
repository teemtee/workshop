# Lesson 1: From Empty Directory to a Working Test Run

**Goal:** By the end, you'll have created every file needed for `tmt run` to work, and you'll know *why* each one exists.

---

## Task 1 — Initialize the tmt workspace

```bash
mkdir -p ~/test-demo/lesson-1 && cd ~/test-demo/lesson-1
tmt init
```

**What just happened:** Look inside your directory.

```bash
ls -la .fmf/
```

This tiny file is the flag that tells tmt "this directory tree contains metadata." Without it, tmt sees nothing.

**Verify:**
```bash
tmt tests ls
```

Returns empty — the root exists but you haven't defined anything yet.

---

## Task 2 — Write the actual test script

Create `test.sh` in your lesson-1 directory:

```bash
#!/bin/bash
echo "Checking if /etc/os-release exists..."
test -f /etc/os-release && echo "PASS: file exists" || exit 1

echo "Checking if bash is available..."
bash --version > /dev/null && echo "PASS: bash works" || exit 1

echo "All checks passed."
```

Make it executable:

```bash
chmod +x test.sh
```

**Why:** This is just a shell script. tmt doesn't care *what* your test does — it only cares about the **exit code**. `0` = pass, anything else = fail. This is the fundamental contract.

**Verify:**
```bash
./test.sh
echo $?    # should print 0
```

---

## Task 3 — Create test metadata

tmt doesn't know your script exists yet. You need to describe it. Create `main.fmf` in the same directory:

```yaml
summary: Basic smoke test for OS essentials
test: ./test.sh
duration: 2m
```

**What each key does:**

| Key | Purpose |
|-----|---------|
| `summary` | Human-readable one-liner (shows up in `tmt tests show`) |
| `test` | The command tmt will execute (relative to this file's directory) |
| `duration` | Max time before tmt kills the test as a timeout |

**Verify:**
```bash
tmt tests ls
```

You should see your test listed. tmt found it.

```bash
tmt tests show
```

This prints the full metadata. Confirm your summary, test command, and duration appear.

---

## Task 4 — The real run

```bash
tmt run --all
```

**Verify:** You should see a **PASS** result.

---

## Task 5 — Make a test fail (on purpose)

Edit `test.sh` — add a line that will fail:

```bash
# add this at the end of test.sh
test -f /nonexistent/file && echo "PASS" || exit 1
```

Run again:

```bash
tmt run --all -vv
```

You should see a **FAIL**. Now inspect:

```bash
tmt run --last report -vvv
```

This shows the detailed output of the failed test — the exact logs from inside the container.

**Lesson:** `--last` re-reads the most recent run's data without re-executing. `-vvv` gives you full output.

---

## Task 6 — Lint your metadata

```bash
tmt lint
```

This validates all your metadata. Green checks = you're good. Run this before pushing changes to catch issues early.

---

## Task 7 — Dry run

```bash
tmt run --all --dry -v
```

**Why:** This walks through the entire pipeline *without actually provisioning or executing anything*. You'll see tmt discover your test, describe what it would execute. No resources consumed. Useful when you want to check your setup without waiting for a container.

**Verify:** Read the output. You should see your test discovered.

---

## What you built

```
~/test-demo/lesson-1/
├── .fmf/
│   └── version            <- "this is an fmf tree"
├── main.fmf               <- WHAT to run (metadata pointing to the script)
└── test.sh                <- the actual test logic
```

**2 files you created, each with a distinct job:**

| File | Role | Key that identifies it |
|------|------|-----------------------|
| `test.sh` | The actual test logic | (just a script, exit 0/1) |
| `main.fmf` | Test metadata | `test:` key |

---

## Lesson 1 checklist

- [ ] Felt the pain of testing manually (Before We Begin)
- [ ] Can explain what `.fmf/version` does
- [ ] Know that exit code 0 = pass, non-zero = fail
- [ ] Created and ran a test in a container
- [ ] Used `--dry`, `--last`, `-vvv`, and `lint`
- [ ] Know where tmt stores run data

---

**Next:** Lesson 2 — creating plans to control where and how tests run, adding dependencies with `require`, and running tests across different OS images.
