---
name: rh-results
description: Ingest experiment results that I copied to the lab server — find the runs, build tables (mean ± std over seeds) and figures with a reusable analysis script, check them against the plan's success criteria, flag anomalies, and write a results summary. Use whenever I say results are in, experiments finished, give a results path, or ask to analyze, compare, tabulate, or plot results.
---

# Ingest results

## 1. Locate
- Which plan and blocks: from what I say, or the `running` blocks of the project.
- Where: the path I give, or `compute.yaml → lab_server.results_root/<project>/<plan-id>/<B>/`.
- Find runs: directories with `run_meta.json` and `DONE`/`FAILED`. For code
  bases not using the wrapper, use the outputs section of the code base map
  (metrics files, eval logs).
- Report missing runs (planned in the grid but absent), `FAILED` runs (last
  lines of `run.log`), and runs with `dirty: true` or a commit different from
  the block branch.

## 2. Analysis script — `projects/<p>/analysis/<plan-id>.py`
Write (or update) a script that is re-runnable on its own:
- inputs: the results paths (arguments or constants at the top);
- parses each run's config and metrics into one dataframe;
- aggregates over seeds: mean ± std and the number of runs per config;
- writes to `projects/<p>/results/<plan-id>/`: `runs.csv`, `table.md`,
  `table.tex`, figures as PNG and PDF.
Plots: one message per figure, labeled axes with units, baseline shown,
error bars when there are several seeds. Use pandas/matplotlib from the
project env (`compute.yaml → lab_server.python_env`); if missing, ask.
Run it. Never copy raw results or checkpoints into the hub; only the
aggregated outputs.

## 3. Interpret — `results/<plan-id>/summary.md` (template `results-summary.md`)
- **Verdict per block** against its success criterion: met / not met /
  inconclusive (e.g. difference smaller than the std, too few seeds).
- **Anomalies:** NaN/inf, identical numbers across configs, huge variance,
  baseline different from previously reported values, suspiciously good results
  (possible data leakage), missing runs.
- **What this suggests next:** 2-4 concrete follow-ups, marked as suggestions.
Be factual. Don't overclaim: say what the numbers show and how sure we can be.

## 4. Finish
`rh set-block <plan> <B> --status results-in --results results/<plan-id>/summary.md`
for each ingested block; when all non-dropped blocks have results,
`rh set-status <plan> results-ingested`. Commit the hub. Reply with the main
table, the verdicts, and anomalies; offer **rh-brief**.
