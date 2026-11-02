# Research hub — instructions for Claude

This directory is my research hub. I'm a PhD researcher in NLP. The hub holds
my research projects with their meeting notes, plans, designs, run guides,
results and briefs. The code bases live elsewhere on this machine and are
linked (symlinks) under `repos/`.

## Layout
- `projects/<project>/`
  - `project.yaml`: goal, status, compute targets, repos (by link name)
  - `project.md`: background, conventions, decisions log
  - `meetings/<date>.md`: raw notes + structured summary, one file per meeting
  - `plans/<plan-id>/plan.md`: experiment plan, blocks, **Block status** table
  - `plans/<plan-id>/design.md`: code-level design
  - `plans/<plan-id>/impl/<block>.md`: implementation logs
  - `codebase/<repo>.md`: map of each code base
  - `guides/<plan-id>/<block>.md`: how to launch on OAR / Jean Zay
  - `analysis/`: analysis scripts; `results/<plan-id>/`: tables, figures, summaries
  - `reports/`: meeting briefs
- `repos/<name>`: symlinks to the real code bases
- `worktrees/<repo>/<branch>`: git worktrees, where all coding happens
- `compute.yaml`: this machine's OAR / Jean Zay settings (no secrets). Private and
  git-ignored: never commit, push or quote it outside this machine.

## Workflow
meeting → plan → design → implement → run guide → *I launch jobs* → results → brief

| Step | Skill | Gate |
|---|---|---|
| Ingest notes | /rh-meeting | — |
| Plan blocks | /rh-plan | **I approve the plan** |
| Code-level design | /rh-design | **I approve the design** |
| Code, test, commit, push branch | /rh-implement | can run unattended |
| Launch scripts + guide | /rh-run-guide | — |
| Ingest results | /rh-results | — |
| Meeting brief | /rh-brief | I edit |
| Overview / resume | /rh-status, /rh-resume | — |
| Projects & repos | /rh-new-project, /rh-import-project, /rh-link-repo | — |
| Fill compute.yaml | /rh-setup-compute | I confirm each value |
| Update the kit | /rh-update | I review and commit |

Never skip a gate unless I explicitly say so for that plan.

Plan statuses: draft → approved → designed → implementing → implemented →
guide-ready → running → results-ingested → done (or abandoned).
Block statuses: planned, designed, implementing, implemented, blocked,
guide-ready, running, results-in, dropped.

## The `rh` tool
Use `rh` for every mechanical step instead of doing it by hand:
`rh status [project]`, `rh repos`, `rh link-repo <path> [--project P]`,
`rh clone-repo <url> <dest> [--project P]`, `rh attach <project> <repo>`,
`rh new-project <name>`, `rh new-meeting <project>`, `rh new-plan <project> "<title>"`,
`rh set-status <plan> <status>`, `rh set-block <plan> <B01> --status … --branch …`,
`rh worktree add|list|remove <repo> <branch>`, `rh paths`, `rh doctor`,
`rh update [--dry-run]`, `rh suggest-compute [--json]`.
Templates live in the kit: `rh paths` shows where.

## Rules
1. **State lives in files.** At the start of any task, read the relevant files;
   never rely on memory of earlier sessions. Update statuses with `rh` as you go.
2. **Code changes only happen in worktrees** (`rh worktree add`) on `block/…`
   branches. Never edit files inside `repos/<name>` directly: I may be working there.
3. **Never move, copy, or delete** the code bases that `repos/` points to.
4. **Never push to main/master, force-push, merge, rebase shared branches, or
   delete branches.** I merge.
5. **Never launch, cancel, or modify cluster jobs** (sbatch, oarsub, scancel,
   oardel), and never use ssh/scp. I operate OAR and Jean Zay myself; you write
   the scripts and guides.
6. **Never handle passwords, tokens, or SSH keys.** If something needs credentials,
   stop and tell me the exact command to run.
7. **Don't invent facts:** dataset names, model ids, hyperparameters, account
   names, paths. Write `TODO` and ask.
8. Run git from inside the repo directory (`cd <dir> && git …`), not `git -C`, so
   the permission rules apply.
9. Keep heavy files (checkpoints, raw results, datasets) out of the hub; reference
   their paths instead.
10. After each step, commit the hub from its root:
    `git add -A projects/<p> && git commit -m "<project>: <what>"`.
11. **Unattended mode.** When I say "go", "run it", or "I'm leaving", don't stop
    for questions that have a reasonable default: decide, record it under
    "Decisions made without you" in the relevant log, and continue. Stop only for
    destructive or irreversible actions, or anything that needs credentials. Finish
    with a short summary message (it triggers a phone notification).
12. Write hub files in English unless the project says otherwise.
