---
name: rh-brief
description: Draft a brief for my next supervisor meeting from everything that happened in a project since the last meeting — results, what didn't work, decisions needed, proposed next experiments. Use whenever I ask to prepare a meeting, a summary for my supervisor, a progress update, slides content, or "what do I tell my supervisor".
---

# Meeting brief

## 1. Gather since the last meeting
The date of the latest file in `meetings/` is the cut-off (or a date I give).
Read: plans updated since then (`updated:` front-matter, Changelog,
Validation log), `impl/*.md` logs, `results/*/summary.md`, the Decisions log in
`project.md`, open questions in plans and meetings, and desktop answers in
`local/` since then. Papers to cite or compare with: the `zotero` tools.

## 2. Write `projects/<p>/reports/<date>-brief.md` (template `brief.md`)
- **TL;DR:** 3 bullets max, the most important first.
- **Results:** the key table(s) (copy from `results/<plan-id>/table.md`) and
  figure paths; one sentence of interpretation each, with its verdict.
- **What didn't work, and why:** failed or blocked blocks, negative results.
  Negative results are results: state them plainly.
- **Decisions needed:** questions only my supervisor can answer, each with
  the options and my current leaning if I stated one.
- **Proposed next experiments:** from the results summaries' suggestions;
  each with expected cost (runs × GPU × hours).
Factual tone, no hype, short. One page if possible.

## 3. Finish
Commit the hub. Show me the brief and ask what to change. If I want it as
slides or a document, help with that as a separate step.
