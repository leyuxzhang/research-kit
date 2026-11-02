---
name: rh-status
description: Overview of every research project in the hub — plans, block statuses, and what is waiting on me. Use whenever I ask "where are we", "status", "what's pending", "what's next", "what's waiting on me", or open a session without naming a project.
---

# Hub status

1. Run `rh status` (or `rh status <project>` if I named one). If no hub is found,
   tell me to run `rh init-hub <path>` and stop.
2. Run `rh repos` and mention any BROKEN link or `dirty` repo, briefly.
3. Answer in a few lines, not a dump of the command output:
   - one line per project: its active plan(s) and stage;
   - **Waiting on you:** plans in `draft` (approve), designs to approve,
     `implemented` blocks to review, `guide-ready` blocks to launch, `running`
     blocks whose results I should copy back, `blocked` blocks (one-line reason
     from `plans/<id>/impl/<block>.md`);
   - **I can do next:** the steps you can take without me, as skill names.
4. End by asking which project to work on, unless I already said.

Keep it short. Don't open plan files unless a status looks inconsistent (for
example a plan `implemented` with blocks still `implementing`); if so, say so.
