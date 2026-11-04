---
name: rh-implement
description: Implement the approved design of a plan block by block — create git worktrees and block branches, write the code and tests, run tests and a smoke test, commit, push the block branches (never main), and log everything — able to run unattended while I'm away. Use whenever a design is approved and I say implement, code it, go, start coding, or continue/resume implementation.
---

# Implement a designed plan

## 0. Preconditions
- Plan status `designed` or `implementing` (resuming), and the design's
  front-matter `status: approved`. Otherwise stop and say what's missing.
- Which blocks: those with status `designed` (or the ones I name), in
  dependency order. Skip `implemented`, `dropped`, and `blocked` ones unless asked.
- This server is shared: if another plan is already `implementing` (`rh status`),
  ask before starting a second one (in unattended mode: don't start; record why
  under "Decisions made without you" and stop).
- `rh set-status <plan> implementing`.

If I said "go", "run it", "I'm leaving", or similar: **unattended mode** (see
the hub CLAUDE.md rule 11). Don't ask questions that have a reasonable default.

## 1. Per block
1. **Worktree** for each repo the block touches:
   `rh worktree add <repo> block/<plan-id>-<B> [--base <branch>]`.
   Work **only** inside these worktree paths. Never edit `repos/<repo>` itself.
2. `rh set-block <plan> <B> --status implementing`.
3. **Implement** what the design says. Follow the code base's style. Keep the
   diff focused: no drive-by refactors or reformatting.
4. **Tests:** add the designed tests; run the relevant existing tests plus the
   new ones (activate the env from `compute.yaml → lab_server.python_env`).
5. **Smoke test:** run the exact command from the design. It must finish and
   produce the expected outputs.
6. **Fix loop:** at most 3 rounds of fixing failures. Still failing →
   the block is `blocked` (see 3).
7. **Launch wrapper:** if the design says so, copy `launch/run_wrapper.sh` from
   the kit templates (`rh paths`) into the repo's `launch/` folder.
8. **Commit** in small logical commits, messages `[<B>] <what>` (body: plan id
   and why). Don't commit data, checkpoints, or outputs; extend `.gitignore` if
   needed.
9. **Push** the branch: `git push -u origin block/<plan-id>-<B>` from the
   worktree. If it fails (no credentials, no remote), don't retry or work around
   it: record "not pushed" and the command I should run.
10. **Log** in `plans/<id>/impl/<B>.md` (template `impl.md`): files changed,
    commits, test and smoke results (the summary lines), deviations from design,
    **Decisions made without you**, limitations, how to review.
11. `rh set-block <plan> <B> --status implemented --branch <branch> --notes "<pushed|not pushed>"`.
12. Commit the hub.

## 2. Unattended decisions
Decide yourself, and log it, when: naming, small API choices, which existing
utility to reuse, adding a missing small test fixture, minor design gaps with
an obvious answer.

Stop the block and mark it `blocked` when: the design is wrong or impossible,
it needs a new dependency in a shared environment, credentials, data you can't
find, or anything destructive. Then **move on** to the next block that doesn't
depend on it.

## 3. Blocked block
`rh set-block <plan> <B> --status blocked --notes "<one line>"`; the impl log
explains what's needed from me. Leave the worktree as it is, with work in
progress committed (`[<B>] WIP: …`) so nothing is lost.

## 4. Never
Push to main/master, force-push, merge, rebase my branches, delete branches,
launch or cancel cluster jobs, install packages into a shared environment
without asking, touch data or checkpoint directories, or edit `repos/<repo>`
directly.

## 5. Finish
When all chosen blocks are `implemented` or `blocked`: if all implemented,
`rh set-status <plan> implemented`. Commit the hub. Final message (it sends a
push notification): a table `Block | Status | Branch | Pushed | Tests | Smoke`,
the decisions made without me, what's blocked and why, and the next step:
review the branches, then **rh-run-guide**.

Several independent blocks may be implemented in parallel with subagents (one
block per subagent, each in its own worktrees) if I ask for it.
