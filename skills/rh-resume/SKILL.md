---
name: rh-resume
description: Load a research project's context and say where it stands, so work can continue in a fresh session. Use whenever I say "resume <project>", "continue <project>", "back to <project>", "let's work on <project>", or mention a project by name at the start of a session.
---

# Resume a project

Each session starts with no memory; the project's files are the memory. Read
them in this order and stop as soon as the picture is clear. Don't read whole
code bases.

1. `rh status <project>`; if the project isn't found, show the list of projects
   and ask.
2. `projects/<p>/project.md` and `project.yaml`.
3. The latest file in `meetings/` (the summary and decisions sections are enough).
4. For each plan not `done`/`abandoned`: its `plan.md`; its `design.md` if it
   exists; its `impl/*.md` logs if blocks are implemented or blocked.
5. For implemented/implementing blocks: `rh worktree list`, and from inside each
   worktree `git log --oneline -5` and `git status --short`, to check the files
   match reality.
6. If a plan has results, read `results/<plan-id>/summary.md`.

Then reply with:
- **Goal** (one line)
- **Last meeting** (date + 2-3 key decisions)
- **Active plan(s)**: stage, blocks and their statuses
- **Open questions / blockers**
- **Suggested next step** (a skill name and what it would do)

Point out any mismatch between files and reality (e.g. a block marked
`implementing` with no worktree, uncommitted changes in a worktree). Then ask
what I want to do.
