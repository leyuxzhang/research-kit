---
name: rh-design
description: Analyze the existing code and turn an approved experiment plan into a code-level design for each block — files and functions to change, code to reuse, tests, smoke test, outputs — then get my approval. Use whenever a plan is approved and I ask to design, plan the code, plan the implementation, analyze the code for the plan, or "what needs to change in the code".
---

# Design the code changes

## 1. Preconditions
- The plan's status is `approved` (or `designed`, if I'm asking for changes).
  If it's `draft`, say so and offer **rh-plan** instead.
- Each repo listed in the plan's blocks has a map in `codebase/`. If one is
  missing, write it first (see **rh-import-project**, step 2).

## 2. Read the code, targeted
For each block not `dropped`: start from the map, then open only the files that
matter (entry points, the module to change, its tests, the configs). Use search
(`rg`) to find call sites. Read from `repos/<repo>`; don't edit anything.

## 3. Write `plans/<id>/design.md`
Start from the template (`rh paths` → templates/`design.md`). For each block:
- **Repos & base branch:** the repo's default branch, unless a block depends on
  another block's branch (then base on that branch and say so).
- **Branch:** `block/<plan-id>-<Bxx>` (same name in every repo the block touches).
- **Files to create / modify:** `path → function/class → change`, precise
  enough to implement.
- **Reused code:** existing functions/classes to call instead of rewriting.
- **Config changes:** new config files or keys, with defaults.
- **Tests:** new unit tests; existing tests that must still pass.
- **Smoke test:** an exact command that exercises the change end to end on tiny
  data in under ~5 minutes on the lab server, respecting `compute.yaml →
  lab_server.smoke_test` (cpu or gpu). If the code base can't do this yet, add
  the minimal support (e.g. a `--max_steps` / `--limit` option) to the design.
- **Outputs:** where runs will write results. Prefer wrapping runs with
  `launch/run_wrapper.sh` (in the kit templates), which records commit, job id,
  exit code and a DONE/FAILED marker; note that the block adds it to the repo.
- **Risks / unknowns** and **Size** (S/M/L).

In **Overview**: implementation order (respecting Depends on), shared changes,
anything that could break existing experiments.

If designing reveals that the plan itself is wrong (impossible metric, missing
data, block too big), say so and propose the plan change instead of designing
around it.

## 4. Approval gate
Summarize as a table `Block | Repos | Main changes | Tests | Smoke test | Size`
plus risks. Ask with AskUserQuestion: **Approve all** / **Approve some** /
**Edit**. Blocks I mark as "auto-OK" may skip this gate in future revisions.
- On approval: set `status: approved` in design.md front-matter;
  `rh set-block <plan> <B> --status designed --branch block/<id>-<B>` for each
  approved block; when all non-dropped blocks are designed,
  `rh set-status <plan> designed`.

## 5. Finish
Commit the hub. Offer **rh-implement**, and mention it can run unattended
("say 'go' and you can leave your desk").
