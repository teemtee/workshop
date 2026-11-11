# Lesson 1: Your First tmt Test

**Goal:** By the end, you'll have created every file needed for `tmt run` to work, and you'll know *why* each one exists.

If you look at the [git repository of this lesson](https://github.com/teemtee/workshop/tree/add-initial-lessons/files/before-we-begin), you'll find the minimal definition of a tmt test. Let's start from scratch in a clean folder and break down what you see step by step.

## Task 1 — Initialize the tmt workspace

```bash
tmt init
```

**What just happened:** Look inside your directory by
```bash
ls -la
```
you will see a folder called `.fmf`.

This is a flag that tells tmt "this directory tree contains metadata." Without it, tmt sees nothing.


## Task 2 — Write the actual test script

Create `test.sh`:

```bash
#!/bin/bash
echo "Checking if /etc/os-release exists..."
test -f /etc/os-release && echo "PASS: file exists" || exit 1

echo "Checking if bash is available..."
bash --version > /dev/null && echo "PASS: bash works" || exit 1

echo "All checks passed."
```

This is just a shell script. tmt doesn't care *what* your test does — it only cares about the **exit code**. `0` is pass, `1` is fail (the test ran, but a check failed), anything else is error.

**Verify:**
```bash
./test.sh
echo $?    # should print 0
```
:::note
Make sure your test script is executable (`chmod +x test.sh`), otherwise tmt won't be able to run it.
:::

## Task 3 — Create test metadata

tmt doesn't know your script exists yet. You need to describe it. Create `main.fmf` in the same directory:

```yaml
test: ./test.sh
```

`test` is the the command tmt will execute (relative to this file's directory)

## Task 4 — The real run

```bash
tmt run
```

**Verify:** You should see a **PASS** result.


## What you built

```
├── .fmf/
│   └── version            <- "this is an fmf tree"
├── test.fmf               <- WHAT to run (metadata pointing to the script)
└── test.sh                <- the actual test logic
```

