# Before We Begin

**Goal:** See what testing looks like with and without tmt, so you understand the problem it solves before building anything yourself.

**Prerequisites:**
- Fedora: `sudo dnf install -y tmt+all`
- Other distros: see [Install](https://tmt.readthedocs.io/en/stable/overview.html#install)


## You have a test

Say you have a simple test — it checks if tree works:

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

You've written the test. Before you open a pull request, you want to know it actually passes — in a clean environment, the way CI will run it, not just on your own cluttered laptop where curl happens to be installed already.

Without tmt you have two options, and neither is great:

- **Push and wait.** Open the pull request and let CI tell you. That means waiting in a queue, possibly for a long time, and when it comes back red you're debugging a remote machine you can't see.
- **Roll your own.** Spin up a container by hand, install the dependencies, mount your code, run the script, clean up afterwards. Now you maintain a second recipe that slowly drifts away from what CI actually does — so "passes locally" stops meaning "passes in CI".

Either way, the feedback loop is slow or unreliable.


## Now do it with tmt

Take the same test script, and add a small metadata file next to it that declares what the test needs:

```yaml
# test.fmf
summary: Check that tree works
test: ./test.sh
require:
  - tree
```

Now check it in a clean container, right from your laptop:

```bash
tmt run --all provision --how container
```

tmt pulls a fresh container, installs tree inside it, runs your test, reports the result, and throws the container away. Your laptop stays untouched, and you get the answer in seconds — no pull request, no queue.

The important part is **fidelity**: this is the same `test.fmf` and the same `tmt run` that CI uses. What passes here passes there. And the environment is just one flag — swap `--how container` for `--how virtual` to run in a full virtual machine, or point it at a remote guest, without touching the test.

tmt doesn't replace your CI — it runs *inside* it. The value is that you can run exactly what CI runs, locally, before you ever push.

**Don't worry if this doesn't fully make sense yet — Lesson 1 walks through every step.**
