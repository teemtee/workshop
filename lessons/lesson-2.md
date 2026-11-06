# Lesson 2: Plans

**Goal:** Learn how to create plans


## Task 1 — Create a plan

A plan defines how your tests are discovered, where they run, and what happens before and after. Let's create one.

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

A plan defines what happens at each step of the pipeline:

- Where to `discover` the tests from, e.g. the test-like objects in the current fmf tree
- How to `provision` the guests where the tests are run, e.g. in a container
- What to do to `prepare` the guest you just provisioned, e.g. install a particular package
- How to `execute` the tests — don't worry about this one, there is practically only one way to do so
- What to `finish` doing before terminating the provisioned guest, e.g. make sure you stop an external server
- Where to `report` the test results, e.g. as a local html file

Now run with the plan:

```bash
tmt run
```

Same test, but now the plan explicitly controls the environment — a Fedora container in this case.

## What you built

```
~/test-demo/lesson-2/
├── .fmf/
│   └── version
├── main.fmf
├── test.sh
└── plans/
    └── basic.fmf              <- run on Fedora
```
