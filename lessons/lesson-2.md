# Lesson 2: Plans

**Goal:** Learn how to create plans to control where your tests run.

**Prerequisites:** Complete Lesson 1.

---

## Task 1 — Set up from Lesson 1

```bash
cp -r ~/test-demo/lesson-1 ~/test-demo/lesson-2
cd ~/test-demo/lesson-2
```

Make sure everything still works:

```bash
tmt run --all
```

You should see a **PASS**.

---

## Task 2 — Create a plan

In Lesson 1, `tmt run --all` ran your test directly on your machine. But what if you want to run it in a container? That's what a plan is for.

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

Now run with the plan (no `--all` needed):

```bash
tmt run
```

Same test, but now it runs inside a Fedora container instead of on your machine.

---

## Task 3 — Run on a different OS

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

```bash
tmt run
```

tmt runs your test under **both** plans — once on Fedora, once on CentOS. Same test, different environments, zero changes to the test itself.

To run only the CentOS plan:

```bash
tmt run plan --name /plans/centos
```

---

## What you built

```
~/test-demo/lesson-2/
├── .fmf/
│   └── version
├── main.fmf
├── test.sh
└── plans/
    ├── basic.fmf              <- run on Fedora
    └── centos.fmf             <- run on CentOS Stream 9
```

| Concept | What it does |
|---------|--------------|
| plan | Control how tests are discovered, where they run, and how they execute |
| `plan --name` | Run only a specific plan |

---

**Next:** Lesson 3 — declaring dependencies with `require` and running tests that need packages.
