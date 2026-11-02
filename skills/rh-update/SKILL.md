---
name: rh-update
description: Update research-kit on this machine (pull the kit, re-link skills, bring template changes into the hub's CLAUDE.md, settings, hub.sh and compute.yaml) and merge any conflicts with me. Use whenever I ask to update, upgrade or sync the kit or the hub, or `rh doctor` says the hub isn't synced or a .kit-new merge is pending.
---

# Update the kit and the hub

## 1. Run the update
`rh update`. It pulls the kit (fast-forward only), re-runs `install.sh`, then
merges kit changes into the hub's copies of the template files, keeping my
edits. If the pull needs credentials, it fails instead of hanging: give me the
exact command (`cd <kit> && git pull --ff-only`), then run `rh update --no-pull`.
If the kit has local changes, stop and tell me; don't stash or reset them.

Use `rh update --dry-run` first if I only want to see what would change.

## 2. Merge pending files
For each `<file>.kit-new` it reports, my file was kept and the kit's new
version sits next to it:
- Show me what the kit changed (diff the two) in a few lines.
- Merge: keep my values and my own additions, take the kit's new text
  (rules, comments, new keys). In `compute.yaml`, never change a value I set;
  new keys come in with their template value (`TODO` if so).
- Ask me only where both sides changed the same thing differently.
- Write the merged file, delete the `.kit-new`, run `rh doctor`.

## 3. Finish
Nothing is committed automatically. Show `git status` for the hub and the
diff summary, and commit only if I say so, with
`git add <the changed files> && git commit -m "Sync hub files with research-kit"`.
Never `git add` compute.yaml: it is private and git-ignored. If `rh update`
just untracked it, that removal goes in the commit, and if the hub was ever
pushed, point me to "Private compute.yaml" in the kit's docs/SETUP.md.

If `hub.sh` changed, remind me to restart the server (the command `rh update`
printed). New sessions pick up the new skills and CLAUDE.md on their own.
