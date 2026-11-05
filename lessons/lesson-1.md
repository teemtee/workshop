# Lesson 1: Your First tmt Test

**Goal:** By the end, you'll have created every file needed for `tmt run` to work, and you'll know *why* each one exists.

If you look at the [git repository of this lesson](https://github.com/teemtee/workshop/tree/main/lessons), you'll find the minimal definition of a tmt test. Let's start from scratch in a clean folder and break down what you see step by step.

## Task 1 — Initialize the tmt workspace

```bash
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

This is just a shell script. tmt doesn't care *what* your test does — it only cares about the **exit code**. `0` is pass, `1` is fail (the test ran, but a check failed), anything else is error (something went wrong outside of the test).

**Verify:**
```bash
./test.sh
echo $?    # should print 0
```


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

:::note
Make sure your test script is executable (`chmod +x test.sh`), otherwise tmt won't be able to run it.
:::

**Verify:**
```bash
tmt tests ls
```

You should see your test listed. tmt found it.

```bash
tmt tests show
```

This prints the full metadata. Confirm your summary, test command, and duration appear.


## Task 4 — The real run

```bash
tmt run --all
```

**Verify:** You should see a **PASS** result.

By default, tmt runs the test directly on your machine. In Lesson 2, you'll learn how to use plans to run tests inside containers instead.


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

