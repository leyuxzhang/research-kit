# research-kit

A reusable Claude Code setup for running NLP research projects from one chat:
meeting notes → experiment plan → code design → implementation → launch
scripts and guides → results → meeting brief.

It is not new software. It is a set of **Claude Code skills** plus a small
helper tool (`rh`), installed on the machine where your code lives. You talk
to it from Claude Desktop (Code tab), claude.ai/code, or the Claude phone app,
through Claude Code's **Remote Control**, so sessions keep running when your
laptop is closed.

## Two repos, two roles
| | What | Where |
|---|---|---|
| **research-kit** (this repo) | Skills, `rh` tool, templates. Same for every project and machine. Public or private. | Installed once per machine |
| **research hub** (created by the kit) | Your projects: notes, plans, designs, guides, results, briefs. Code bases are only *linked*. | One per machine; its own private git repo |

## Install (on the lab server)
```bash
git clone <your-github>/research-kit.git ~/tools/research-kit
cd ~/tools/research-kit
./install.sh --hub ~/research-hub
rh doctor
```
Then follow [docs/SETUP.md](docs/SETUP.md) to fill `compute.yaml` and start the
always-on Remote Control server.

## Skills
| Skill | Does |
|---|---|
| `/rh-status` | Overview of all projects and what's waiting on you |
| `/rh-resume <project>` | Load a project's context in a fresh session |
| `/rh-new-project` | New project; link or clone its code bases |
| `/rh-import-project` | Adopt existing code bases (linked in place) and map them |
| `/rh-link-repo` | Link / clone / attach / unlink repos |
| `/rh-meeting` | Raw notes, transcript or photo → structured meeting file |
| `/rh-plan` | Meeting → experiment blocks; **you approve** |
| `/rh-design` | Read the code → file-level design per block; **you approve** |
| `/rh-implement` | Worktrees, code, tests, smoke test, commits, push block branches; runs unattended |
| `/rh-run-guide` | OAR + Jean Zay scripts and a step-by-step launch guide (you launch) |
| `/rh-results` | Results → tables, figures, verdicts vs. success criteria |
| `/rh-brief` | Draft for the next supervisor meeting |

You can also just talk normally ("here are today's notes", "resume project X");
skills trigger from their descriptions.

## Guardrails
- Code bases are **linked, never moved**; coding happens in git worktrees under
  `hub/worktrees/` on `block/...` branches. Your own checkout is never edited.
- Claude never pushes to main, force-pushes, merges, launches or cancels jobs,
  uses ssh/scp, or touches passwords and keys (rules in the hub's `CLAUDE.md`
  and deny-rules in `.claude/settings.json`).
- Permission rules are guardrails, not a sandbox: in unattended mode Claude
  runs Python and tests as your user. Review branches before merging.

## Layout
```
bin/rh                  helper CLI (python, stdlib only)
skills/rh-*/SKILL.md    the skills
templates/              plan, design, meeting, guide, results, brief templates
templates/launch/       OAR and Slurm script templates, run wrapper
hub-template/           what `rh init-hub` creates
docs/SETUP.md           step-by-step setup, SSH notes, troubleshooting
```

## Updating
`cd ~/tools/research-kit && git pull && ./install.sh` — skills are symlinked,
so edits to the kit apply to every session immediately.

## Later: automating Jean Zay
Launch scripts are already generated per block. Automating submission later
means adding a submit/monitor command to `rh` that runs these same scripts and
removing `sbatch`/`ssh` from the hub's deny-rules. Nothing else changes.
