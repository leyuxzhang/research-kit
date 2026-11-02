---
name: rh-new-project
description: Create a new research project in the hub, with its folders, goal, and code bases (existing local repos are linked, new ones cloned where I choose). Use whenever I want to start, create, or set up a new research project or idea that needs its own space. For adopting an existing code base with analysis, use rh-import-project.
---

# New project

## Gather (ask only for what's missing, in one message)
- **Name** (short, it becomes a folder name)
- **Goal** (one sentence)
- **Code bases**, each one either:
  - already on this machine → its path (it will be **linked**, never moved);
  - to clone → URL **and** the directory where I want the clone;
  - none yet.
- **Compute targets** (default: oar and jeanzay)

## Do
1. `rh new-project "<name>" --goal "<goal>"`
2. For each code base:
   - local: `rh link-repo <path> --project <name> --role "<what it's for>"`
   - clone: `rh clone-repo <url> <dest> --project <name> --role "<role>"`.
     If the clone fails because it needs credentials, give me the exact
     `git clone` command to run myself, then `rh link-repo` it once I confirm.
3. If compute targets differ from the default, edit `compute:` in `project.yaml`.
4. Fill `project.md`: the goal, plus any background I gave. Put `TODO` where
   things are unknown; don't invent.
5. Commit the hub: `git add -A projects/<name> && git commit -m "<name>: new project"`.

## Then
Summarize what was created (paths, linked repos). If any repo has no map in
`codebase/`, offer to run **rh-import-project** to analyze it — the designs
will be much better with it. Otherwise offer **rh-meeting** to ingest the
first notes.
