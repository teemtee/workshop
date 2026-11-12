# Lesson 1: Your First tmt Test

**Goal:** By the end, you'll have created every file needed for `tmt run` to work, and you'll know *why* each one exists.

If you look at the [git repository of this lesson](https://github.com/teemtee/workshop/tree/main/lessons/lesson-1), you'll find the minimal definition of a tmt test. Let's start from scratch in a clean folder and break down what you see step by step.

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
curl --version
if [ $? -eq 0 ]; then
    echo "PASS: curl works"
    exit 0
else
    echo "FAIL: curl not found"
    exit 1
fi
```

:::{important}
Make sure your test script is executable (`chmod +x test.sh`), otherwise tmt won't be able to run it.
:::

This is just a shell script. tmt doesn't care *what* your test does — it only cares about the **exit code**. `0` is pass, `1` is fail (the test ran, but a check failed), anything else is error.

**Verify:**
```bash
./test.sh # should print "PASS: curl works"
echo $?    # should print 0
```
## Task 3 — Create test metadata

tmt doesn't know your script exists yet. You need to describe it. Create `test.fmf` in the same directory:

```yaml
test: ./test.sh
```

`test` is the command tmt will execute (relative to this file's directory)

## Task 4 — The real run

```bash
tmt run
```

**Verify:** You should see something like **1 test passed** as below:

```console
/var/tmp/tmt/run-025

/default/plan
    discover
        directory: /home/mdhrahma/Documents/programming/red-hat/tmt/tmt-lesson-draft/lesson-1
        how: fmf
        summary: 1 test selected
    provision
        queued provision.provision tasks
            #1: default-0
        
        provision.provision task #1: default-0
        how: virtual
        ansible: {}

        memory: 2048 MB
        disk: 40 GB
        progress: booting...
        multihost name: default-0
        arch: x86_64
        distro: Fedora Linux 45 (Cloud Edition)
        queued push tasks
            #1: push to default-0
        
        push task #1: push to default-0
    
        summary: 1 guest provisioned
    prepare
        queued push tasks
            #1: push to default-0
        
        push task #1: push to default-0
    
        queued prepare tasks
            #1: essential-requires on default-0
        
        prepare task #1: essential-requires on default-0
        how: install
        summary: Install essential required packages
        name: essential-requires
        where: default-0
        package: /usr/bin/flock
    
        queued pull tasks
            #1: pull from default-0
        
        pull task #1: pull from default-0
    
        summary: 1 preparation applied
    execute
        queued execute tasks
            #1: default-0 on default-0
        
        execute task #1: default-0 on default-0
        how: tmt
        progress:            
    
        summary: 1 test executed
    finish
        queued finish tasks
    
        summary: 0 tasks completed
    report
        how: display
        summary: 1 test passed
    cleanup
        queued cleanup tasks
            #1: default-0 on default-0
        
        cleanup task #1: default-0 on default-0
        how: tmt
        console.txt: /var/tmp/tmt/run-025/default/plan/provision/default-0/logs/console.txt
        guest: stopped
        guest: removed
        summary: 1 task completed

total: 1 test passed
```


## What you built

```
├── .fmf/
│   └── version            <- "this is an fmf tree"
├── test.fmf               <- WHAT to run (metadata pointing to the script)
└── test.sh                <- the actual test logic
```

