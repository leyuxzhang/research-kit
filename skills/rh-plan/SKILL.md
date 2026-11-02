---
name: rh-plan
description: Turn meeting decisions and research ideas into a concrete experiment plan made of blocks — or update an existing plan by adding, modifying, or dropping blocks — then get my approval. Use whenever I ask to plan, organize experiments, define blocks, turn notes or ideas into a plan, or change what experiments we'll run.
---

# Plan experiments

A plan is research ideas translated into engineering: concrete enough that
someone could implement and run each block without asking what I meant.

## 1. Read first
- The source meeting(s) (`meetings/…`), `project.md` (conventions!), the
  project's active plans, and `codebase/*.md` maps.
- `compute.yaml` for realistic compute targets.

## 2. New plan or update?
- New direction → `rh new-plan <project> "<title>" [--slug …]` and fill it.
- Changes to an existing plan → edit it in place:
  - add blocks with the next free ids (never reuse an id);
  - modified blocks: edit, and note what changed in **Changelog**;
  - dropped blocks: `rh set-block <plan> <B0x> --status dropped --notes "<why>"`;
    keep their section, add "(dropped)" to the heading;
  - if the plan was already approved or later, set it back to `draft`
    (`rh set-status <plan> draft`) — changes need approval again.
- Add the meeting path(s) to `source_meetings`.

## 3. Write the blocks
For each block fill every field of the template. Guidelines:
- **Small and independent:** one coherent code change + the experiments
  using it. If a shared change serves several blocks, make it its own block
  and list it in **Depends on**.
- **Concrete:** exact datasets and splits, exact model ids, config values or
  grids, seeds, metrics with their implementation (e.g. "macro-F1 via sklearn"),
  baselines to compare against.
- **Measurable success criteria** ("≥ +1 point macro-F1 over B00 baseline,
  mean of 3 seeds"), or say explicitly that the block is exploratory.
- **Compute estimate and target** (oar / jeanzay) consistent with `compute.yaml`.
- Unknown facts (dataset version, model size, account) → `TODO` + an entry in
  **Open questions**. Never invent them.

Add one row per block to the **Block status** table:
`rh set-block <plan> B01 --status planned --repos "<repos>"`.

## 4. Approval gate
Show a compact summary: objective, then a table
`Block | What | Repos | Runs × GPU × h | Target | Depends on`, then open
questions. Ask with AskUserQuestion: **Approve** / **Edit** / **Discard**.
- Edit → apply my changes, show the summary again.
- Approve → `rh set-status <plan> approved`; add a line to **Validation log**
  ("<date> — approved", plus edits made). Don't approve on your own, even
  in unattended mode.
- Discard → `rh set-status <plan> abandoned` and record why.

## 5. Finish
Commit the hub (`<p>: plan <id> <status>`). If approved, offer **rh-design**.
