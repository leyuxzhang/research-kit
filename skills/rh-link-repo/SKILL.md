---
name: rh-link-repo
description: Link an existing local code base into the hub, clone a new one to a location I choose and link it, attach a repo to a project, list linked repos, or remove a link. Use whenever I mention adding, linking, cloning, connecting, or removing a repository/code base, or ask which repos are available.
---

# Manage repo links

The hub never holds code: `repos/<name>` is a symlink to wherever the code
really is. Linking never moves, copies, or modifies the code base.

- **Link an existing repo:** `rh link-repo <path> [--name N] [--project P] [--role R]`
- **Clone then link:** `rh clone-repo <url> <dest> [--name N] [--project P] [--role R]`
  - `<dest>` is an existing directory (the clone goes inside it) or the exact
    target path. Always use the location I asked for; if I didn't say, ask.
  - If cloning needs a password or token, `rh` fails instead of hanging: give
    me the exact `git clone` command to run myself, then link the result.
- **Attach a linked repo to a project:** `rh attach <project> <repo> [--role R]`
- **List / check:** `rh repos` (BROKEN means the target moved or was deleted:
  ask me where it is now, then `rh unlink-repo` + `rh link-repo`).
- **Remove a link:** `rh unlink-repo <name>` — removes only the link. Never
  delete the target directory, even if asked casually; tell me to do it myself.

`rh` also records each repo's real path in `.claude/settings.local.json`
(`additionalDirectories`) so Claude can work in it without prompting.

After linking a repo that isn't mapped yet (no `projects/*/codebase/<repo>.md`),
offer **rh-import-project** to analyze it. Commit hub changes if a
`project.yaml` changed.
