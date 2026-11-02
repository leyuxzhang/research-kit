---
name: rh-run-guide
description: Write ready-to-submit launch scripts (OAR and Jean Zay/Slurm) for implemented blocks and a step-by-step guide I follow to launch the experiments myself and bring the results back. Use whenever blocks are implemented and I ask how to run them, want launch or submission scripts, a run guide, or say I'm about to launch on OAR, Jean Zay, Slurm, or the cluster.
---

# Launch scripts and run guide

I launch jobs myself; you prepare everything so that launching is copy-paste.
You never run `oarsub`, `sbatch`, `ssh`, or `scp`.

## 1. Read
- `compute.yaml` (machine settings), the plan, `design.md`, `impl/<B>.md`, and
  the code base map (how to run training/eval, where outputs go).
- Which blocks: `implemented` ones (or those I name). Which target: the block's
  **Target**, or what I say ("Jean Zay quota is low, use OAR").

## 2. Scripts — in the repo, on the block branch
Work in the block's worktree. Fill the kit templates (`rh paths` → templates/launch):
- `launch/oar/<B>.sh` from `oar.sh`
- `launch/slurm/<B>.slurm` from `slurm.sbatch`
- `launch/run_wrapper.sh` if it isn't in the repo yet

Filling rules:
- Values come from `compute.yaml`, the plan (runs, GPU type, hours), and the
  design (command, outputs). A value that's `TODO` in `compute.yaml` stays
  `TODO` in the script and is listed at the top of the guide. Never guess
  account names, QoS, module versions, or paths.
- Remove placeholder lines that don't apply (e.g. an empty `{{property_line}}`).
- `{{run_dir}}`: `<results_root>/<project>/<plan-id>/<B>/<run-name>`, unique per run.
- Grids/seeds: use a job array and a `launch/<B>.grid` file with one argument
  line per run; select the line with `OAR_ARRAY_INDEX` (starts at 1) or
  `SLURM_ARRAY_TASK_ID`. Array syntax: Slurm `#SBATCH --array=1-N`,
  OAR `#OAR --array N`.
- Jean Zay compute nodes have **no internet**: keep the offline env vars, and
  list in the guide which models/datasets must be downloaded beforehand from a
  login node (exact commands).
- Record the commit hash in the script header.
- Check syntax: `bash -n <script>`.

Commit (`[<B>] launch scripts`) and push the block branch as in rh-implement,
so the cluster can `git pull` it.

## 3. Guide — `projects/<p>/guides/<plan-id>/<B>.md`
From the template `run-guide.md`. Exact commands in order, nothing vague:
- **Before the first run:** environment, downloads, `mkdir -p` for logs and
  results.
- **Option A — OAR:** connect to the frontend (I do this), `cd <code_root>/<repo>`,
  `git fetch && git checkout block/<plan-id>-<B> && git pull`, verify the commit,
  `oarsub -S launch/oar/<B>.sh`, monitor with `oarstat -u`, where logs are.
- **Option B — Jean Zay:** connect (I do this), `cd <code_root>/<repo>`, same git
  steps, pre-downloads on the login node, `sbatch launch/slurm/<B>.slurm`,
  `squeue -u $USER`, where logs are.
- **Check that it worked:** `DONE` / `FAILED` files, `run_meta.json`, the log
  lines that matter.
- **Bring results back:** an `rsync -av` command from the cluster's results dir
  to `compute.yaml → lab_server.results_root/<project>/<plan-id>/<B>/`, run
  from a machine that can reach both (I'll choose). Copy metrics and logs,
  not checkpoints, unless the analysis needs them.
- **Then:** "tell Claude: results for <B> are in <path>".

## 4. Finish
`rh set-block <plan> <B> --status guide-ready --guide guides/<plan-id>/<B>.md`;
when all non-dropped blocks are guide-ready, `rh set-status <plan> guide-ready`.
Commit the hub. Reply with: the TODOs I must fill, then the 3-5 commands to
launch (the guide has the rest). When I say I've launched them:
`rh set-block … --status running` and `rh set-status <plan> running`.
