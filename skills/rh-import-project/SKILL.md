---
name: rh-import-project
description: Bring an existing research project and its code base(s) into the hub — link the repos where they already are (no move, no copy) and write a map of each code base so later designs reuse the existing code correctly. Use whenever I want to import, add, onboard, adopt, register or "upload" an existing project or code base, or when a linked repo has no code base map yet.
---

# Import an existing project

The goal is a code base map good enough that **rh-design** can say "change
function X in file Y" without re-reading the whole repository each time.

## 1. Link (never move, copy, or modify the code)
- Ask for: project name (existing or new), goal (one line if new), and the
  path of each code base on this machine.
- New project: `rh new-project "<name>" --goal "<goal>"`.
- Each repo: `rh link-repo <path> --project <name> --role "<role>"`.
  For a repo that's only on GitHub, use `rh clone-repo` to a place I choose.

## 2. Map each code base → `projects/<p>/codebase/<repo>.md`
Start from the template (`rh paths` shows the templates folder;
`codebase-map.md`). Work from inside `repos/<repo>`, reading only; no edits,
no commits, no checkout.

Gather, cheapest first:
- `git remote -v`, `git branch -a`, `git log --oneline -10`, current commit.
- README, docs, `pyproject.toml` / `requirements*.txt` / `environment.yml`.
- Material that isn't on this server (notes, slides, exported results on my
  desktop): ask me, then **rh-local**; papers: the `zotero` tools. List them
  in `projects/<p>/sources.md`.
- A tree of the repo, skipping data, checkpoints, outputs, `.git`, caches.
- Entry points: search for `if __name__ == "__main__"`, `argparse`, `hydra`,
  `click`, `typer`, `Trainer(`, and scripts in `scripts/`, `bin/`, `tools/`.
- Configs: YAML/JSON configs, Hydra config dirs, default values.
- Outputs: where checkpoints, metrics, and logs are written; W&B or TensorBoard.
- Tests: `tests/`, pytest config; how long they take (don't run them yet).
- How experiments are launched today: existing `*.slurm`, `*.sbatch`, OAR
  scripts, shell wrappers.

Write the map concisely: paths, function/class names, one-line explanations.
Note anything surprising under **Gotchas**. If something can't be determined,
write `TODO` rather than guessing.

## 3. Optional, only with my consent
- Run the test suite once to record its state ("12 passed, 2 failing: …").
- Add a short `CLAUDE.md` inside the repo, on a branch `chore/claude-setup`
  created in a worktree (`rh worktree add <repo> chore/claude-setup`). Never on
  the current branch of my checkout.

## 4. Finish
- Fill `project.md` (goal, background I gave, conventions you noticed, e.g.
  "all configs are Hydra YAML in conf/").
- Commit the hub: `git add -A projects/<p> && git commit -m "<p>: import"`.
- Reply with a 5-10 line summary per repo (entry points, config system,
  outputs, tests) and ask me to correct anything wrong. Corrections go into the
  map: it is the base for every future design.
