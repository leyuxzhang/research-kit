---
name: rh-setup-compute
description: Fill the hub's compute.yaml (results paths, OAR frontend and resources, Jean Zay account, QoS, modules, Python env) from values already used on this machine, confirming each one with me. Use whenever I ask to set up, fill, configure or check compute.yaml, cluster settings, or when `rh doctor` reports TODO values left in it.
---

# Fill compute.yaml

`compute.yaml` (hub root) holds this machine's cluster settings. It is private:
git-ignored, never committed, pushed or quoted outside this machine.

## 1. Collect suggestions — only through `rh`
Run `rh suggest-compute --json`. It scans the launch scripts in linked repos,
Claude Code transcripts, shell history and this machine (nvidia-smi, oarsub,
conda), and returns only matched values with where they came from.

**Never read shell history, `~/.claude/projects/**` transcripts,
`~/.claude/history.jsonl` or `~/.ssh/**` yourself**: they can contain
passwords and tokens. `rh` extracts values without exposing the rest.

Read `compute.yaml` too: each key's comment says the type of value it takes.

## 2. Confirm with me, key by key
For each key that is still `TODO` (and any `set` key where a suggestion
differs from the current value), ask me, a few keys per question, grouped by
section (lab_server, oar, jeanzay):
- offer the top candidates as options, each labelled with its sources and
  count (e.g. `abc — 12x repos/llm-ft/train.slurm`);
- say plainly when there is no evidence, and let me type the value;
- point out weak evidence (a single hit, or a value that only came from a
  path heuristic, like `code_root` / `results_root`).

Lab-server history rarely shows Jean Zay values ($WORK paths, module
versions, `idrproj` output). When those are missing, give me the exact command
to run on Jean Zay to find each one (`idrproj`, `echo $WORK`,
`module avail pytorch`) and let me paste the answer.

Never write a value I didn't confirm. "Skip" leaves it `TODO`.

## 3. Write
Edit `compute.yaml` in place: keep every comment, change only values.
- Quote strings containing `: # ' "` or starting with `$` or `/` when needed
  (see the type legend at the top of the file).
- Shell-block keys (`oar.env_setup`, `jeanzay.modules`, `jeanzay.env_setup`):
  replace the `# TODO …` lines inside the block with the confirmed commands,
  indented under the key. For `oar.env_setup`, offer the confirmed
  `lab_server.python_env` command when the OAR nodes share this environment.
- `jeanzay.gpus.*.qos` are inside flow maps: edit only the `qos:` field.

## 4. Finish
Run `rh doctor` and tell me how many TODO values are left and which. Don't
commit anything: compute.yaml is git-ignored on purpose.
